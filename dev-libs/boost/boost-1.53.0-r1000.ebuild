# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
PYTHON_DEPEND="python? ( <<>> )"
PYTHON_RESTRICTED_ABIS="*-jython *-pypy"

inherit eutils flag-o-matic multilib multilib-minimal multiprocessing python toolchain-funcs

MY_P="${PN}_${PV//./_}"

DESCRIPTION="Boost libraries for C++"
HOMEPAGE="http://www.boost.org/ https://github.com/boostorg"
SRC_URI="mirror://sourceforge/boost/${MY_P}.tar.bz2"

LICENSE="Boost-1.0"
SLOT="0/${PV}"
KEYWORDS="*"
IUSE="c++11 context debug doc icu mpi +nls python static-libs +threads tools"
REQUIRED_USE="mpi? ( threads )"
RESTRICT="test"

RDEPEND="icu? ( >=dev-libs/icu-3.6:0=::${REPOSITORY}[c++11(-)=,${MULTILIB_USEDEP}] )
	!icu? ( virtual/libiconv[${MULTILIB_USEDEP}] )
	mpi? ( || ( sys-cluster/openmpi[cxx] sys-cluster/mpich2[cxx,threads] ) )
	app-arch/bzip2:0=[${MULTILIB_USEDEP}]
	sys-libs/zlib:0=[${MULTILIB_USEDEP}]
	!app-admin/eselect-boost
	abi_x86_32? ( !app-emulation/emul-linux-x86-cpplibs[-abi_x86_32(-)] )"
DEPEND="${RDEPEND}
	>=dev-util/boost-build-${PV}"

S="${WORKDIR}/${MY_P}"

c++11_checks() {
	if use c++11; then
		if [[ $(tc-getCXX) == *g++* ]]; then
			if test-flag-CXX -std=gnu++11; then
				append-cxxflags -std=gnu++11
			else
				eerror "GCC >=4.7 required for support for C++11"
				die "C++11 not supported by currently used C++ compiler"
			fi
		else
			if test-flag-CXX -std=c++11; then
				append-cxxflags -std=c++11
			else
				die "C++11 not supported by currently used C++ compiler"
			fi
		fi
	fi
}

create_user-config.jam() {
	local compiler compiler_version compiler_executable

	if [[ ${CHOST} == *-darwin* ]]; then
		compiler="darwin"
		compiler_version="$(gcc-fullversion)"
		compiler_executable="$(tc-getCXX)"
	else
		compiler="gcc"
		compiler_version="$(gcc-version)"
		compiler_executable="$(tc-getCXX)"
	fi
	local mpi_configuration python_configuration

	if multilib_is_native_abi && use mpi; then
		mpi_configuration="using mpi ;"
	fi

	if multilib_is_native_abi && use python; then
		if tc-is-cross-compiler; then
			python_configuration="using python : $(python_get_version) : ${SYSROOT}/usr : ${SYSROOT}$(python_get_includedir) : ${SYSROOT}/usr/$(get_libdir) ;"
		else
			python_configuration="using python : $(python_get_version) : /usr : $(python_get_includedir) : /usr/$(get_libdir) ;"
		fi
	fi

	cat > "${BOOST_ROOT}/user-config.jam" << __EOF__
using ${compiler} : ${compiler_version} : ${compiler_executable} : <cflags>"${CFLAGS}" <cxxflags>"${CXXFLAGS}" <linkflags>"${LDFLAGS}" ;
${mpi_configuration}
${python_configuration}
__EOF__
}

pkg_pretend() {
	c++11_checks
}

pkg_setup() {
	if use python; then
		python_pkg_setup
	fi
}

src_prepare() {
	epatch \
		"${FILESDIR}/${PN}-1.52.0-glibc-2.18.patch" \
		"${FILESDIR}/${PN}-1.53.0-graph_parallel_c++11.patch" \
		"${FILESDIR}/${PN}-1.53.0-library_status_c++98.patch" \
		"${FILESDIR}/${PN}-1.53.0-wave_c++11.patch" \
		"${FILESDIR}/${PN}-1.51.0-mpi_c++11.patch" \
		"${FILESDIR}/${PN}-1.48.0-mpi_python3.patch" \
		"${FILESDIR}/${PN}-1.52.0-no_threads.patch" \
		"${FILESDIR}/${PN}-1.51.0-respect_python-buildid.patch" \
		"${FILESDIR}/${PN}-1.51.0-support_dots_in_python-buildid.patch" \
		"${FILESDIR}/${PN}-1.48.0-no_strict_aliasing_python2.patch" \
		"${FILESDIR}/${PN}-1.48.0-disable_libboost_python3.patch" \
		"${FILESDIR}/${PN}-1.48.0-python_linking.patch" \
		"${FILESDIR}/${PN}-1.52.0-disable_icu_libraries_search_paths.patch"

	local file
	for file in libs/context/src/asm/*.S; do
		cat - >> "${file}" <<EOF

#if defined(__linux__) && defined(__ELF__)
.section .note.GNU-stack,"",%progbits
#endif
EOF
	done

	epatch_user

	multilib_copy_sources
}

ejam() {
	local arguments=(
		--user-config="${BOOST_ROOT}/user-config.jam"
		--boost-build="${EPREFIX}/usr/share/boost-build"
		--prefix="${ED}usr"
		--layout=system
		-d+2
		-j$(makeopts_jobs)
		-q
		$(usex debug gentoodebug gentoorelease)
		link=$(usex static-libs shared,static shared)
		pch=off
		threading=$(usex threads multi single)
	)

	if ! use context; then
		arguments+=(--without-context)
	fi

	if use icu; then
		arguments+=(-sICU_PATH="${EPREFIX}/usr")
	else
		arguments+=(--disable-icu boost.locale.icu=off)
	fi

	if ! multilib_is_native_abi || ! use mpi; then
		arguments+=(--without-mpi)
	fi

	if ! use nls; then
		arguments+=(--without-locale)
	fi

	if multilib_is_native_abi && use python; then
		if [[ -n "${PYTHON_ABI}" ]]; then
			arguments+=(--python-buildid=${PYTHON_ABI})
		fi
	else
		arguments+=(--without-python)
	fi

	if [[ "${CHOST}" == *-winnt* ]]; then
		arguments+=(-sNO_BZIP2=1)
	fi

	echo b2 "${arguments[@]}" "$@"
	b2 "${arguments[@]}" "$@"
}

src_configure() {
	[[ "$(makeopts_jobs)" -gt 64 ]] && MAKEOPTS+=" -j64"

	c++11_checks

	if use icu; then
		# https://svn.boost.org/trac/boost/ticket/7636
		append-cxxflags $(icu-config --cxxflags)
	fi

	if [[ ${CHOST} == *-darwin* ]]; then
		# We need to add the prefix, and in two cases this exceeds, so prepare
		# for the largest possible space allocation.
		append-ldflags -Wl,-headerpad_max_install_names
	elif [[ ${CHOST} == *-winnt* ]]; then
		compiler=parity
		if [[ $($(tc-getCXX) -v) == *trunk* ]]; then
			compilerVersion=trunk
		else
			compilerVersion=$($(tc-getCXX) -v | sed '1q' \
				| sed -e 's,\([a-z]*\) \([0-9]\.[0-9]\.[0-9][^ \t]*\) .*,\2,')
		fi
		compilerExecutable=$(tc-getCXX)
	fi

	# bug 298489
	if use ppc || use ppc64; then
		[[ $(gcc-version) > 4.3 ]] && append-flags -mno-altivec
	fi


}

multilib_src_compile() {
	local -x BOOST_ROOT="${BUILD_DIR}"
	PYTHON_DIRS=""
	MPI_PYTHON_MODULE=""

	building() {
		create_user-config.jam

		ejam || die "Building of Boost libraries failed"

		if multilib_is_native_abi && use python; then
			if [[ -z "${PYTHON_DIRS}" ]]; then
				PYTHON_DIRS="$(find bin.v2/libs -name python | sort)"
			else
				if [[ "${PYTHON_DIRS}" != "$(find bin.v2/libs -name python | sort)" ]]; then
					die "Inconsistent structure of build directories"
				fi
			fi

			local dir
			for dir in ${PYTHON_DIRS}; do
				mv ${dir} ${dir}-${PYTHON_ABI} || die "Renaming of '${dir}' to '${dir}-${PYTHON_ABI}' failed"
			done

			if multilib_is_native_abi && use mpi; then
				if [[ -z "${MPI_PYTHON_MODULE}" ]]; then
					MPI_PYTHON_MODULE="$(find bin.v2/libs/mpi/build/*/gentoo* -name mpi.so)"
					if [[ "$(echo "${MPI_PYTHON_MODULE}" | wc -l)" -ne 1 ]]; then
						die "Multiple mpi.so files found"
					fi
				else
					if [[ "${MPI_PYTHON_MODULE}" != "$(find bin.v2/libs/mpi/build/*/gentoo* -name mpi.so)" ]]; then
						die "Inconsistent structure of build directories"
					fi
				fi

				mv stage/lib/mpi.so stage/lib/mpi.so-${PYTHON_ABI} || die "Renaming of 'stage/lib/mpi.so' to 'stage/lib/mpi.so-${PYTHON_ABI}' failed"
			fi
		fi
	}
	if multilib_is_native_abi && use python; then
		python_execute_function building
	else
		building
	fi

	if multilib_is_native_abi && use tools; then
		pushd tools > /dev/null || die
		ejam || die "Building of Boost tools failed"
		popd > /dev/null || die
	fi
}

multilib_src_install() {
	local -x BOOST_ROOT="${BUILD_DIR}"

	installation() {
		create_user-config.jam

		if multilib_is_native_abi && use python; then
			local dir
			for dir in ${PYTHON_DIRS}; do
				cp -pr ${dir}-${PYTHON_ABI} ${dir} || die "Copying of '${dir}-${PYTHON_ABI}' to '${dir}' failed"
			done

			if multilib_is_native_abi && use mpi; then
				cp -p stage/lib/mpi.so-${PYTHON_ABI} "${MPI_PYTHON_MODULE}" || die "Copying of 'stage/lib/mpi.so-${PYTHON_ABI}' to '${MPI_PYTHON_MODULE}' failed"
				cp -p stage/lib/mpi.so-${PYTHON_ABI} stage/lib/mpi.so || die "Copying of 'stage/lib/mpi.so-${PYTHON_ABI}' to 'stage/lib/mpi.so' failed"
			fi
		fi

		ejam \
			--includedir="${ED}usr/include" \
			--libdir="${ED}usr/$(get_libdir)" \
			install || die "Installation of Boost libraries failed"

		if multilib_is_native_abi && use python; then
			rm -r ${PYTHON_DIRS} || die

			# Move mpi.so Python module to Python site-packages directory.
			# https://svn.boost.org/trac/boost/ticket/2838
			if multilib_is_native_abi && use mpi; then
				dodir $(python_get_sitedir)/boost
				mv "${ED}usr/$(get_libdir)/mpi.so" "${ED}$(python_get_sitedir)/boost" || die
				cat << EOF > "${ED}$(python_get_sitedir)/boost/__init__.py" || die
import sys
if sys.platform.startswith('linux'):
	import DLFCN
	flags = sys.getdlopenflags()
	sys.setdlopenflags(DLFCN.RTLD_NOW | DLFCN.RTLD_GLOBAL)
	from . import mpi
	sys.setdlopenflags(flags)
	del DLFCN, flags
else:
	from . import mpi
del sys
EOF
			fi
		fi
	}
	if multilib_is_native_abi && use python; then
		python_execute_function installation
	else
		installation
	fi

	pushd "${ED}usr/$(get_libdir)" > /dev/null || die

	local ext=$(get_libname)
	if use threads; then
		local f
		for f in *${ext}; do
			dosym ${f} /usr/$(get_libdir)/${f/${ext}/-mt${ext}}
		done
	fi

	popd > /dev/null || die

	if multilib_is_native_abi && use tools; then
		dobin dist/bin/*

		insinto /usr/share
		doins -r dist/share/boostbook
	fi
}

multilib_src_install_all() {
	if ! use context; then
		rm -r "${ED}usr/include/boost/context" || die
		rm -r "${ED}usr/include/boost/coroutine" || die
	fi

	if ! use nls; then
		rm -r "${ED}usr/include/boost/locale"* || die
	fi

	if ! use python; then
		rm -r "${ED}usr/include/boost/python"* || die
	fi

	if use doc; then
		find libs/*/* -iname "test" -or -iname "src" | xargs rm -rf
		dohtml \
			-A pdf,txt,cpp,hpp \
			*.{htm,html,png,css} \
			-r doc
		dohtml -A pdf,txt -r tools
		insinto /usr/share/doc/${PF}/html
		doins -r libs
		doins -r more

		# To avoid broken links
		insinto /usr/share/doc/${PF}/html
		doins LICENSE_1_0.txt

		dosym /usr/include/boost /usr/share/doc/${PF}/html/boost
	fi

	# boost's build system truely sucks for not having a destdir.  Because for
	# this reason we are forced to build with a prefix that includes the
	# DESTROOT, dynamic libraries on Darwin end messed up, referencing the
	# DESTROOT instread of the actual EPREFIX.  There is no way out of here
	# but to do it the dirty way of manually setting the right install_names.
	if [[ ${CHOST} == *-darwin* ]]; then
		einfo "Working around completely broken build-system(tm)"
		local d
		for d in "${ED}"usr/lib/*.dylib; do
			if [[ -f ${d} ]]; then
				# fix the "soname"
				ebegin "  correcting install_name of ${d#${ED}}"
				install_name_tool -id "/${d#${D}}" "${d}"
				eend $?
				# fix references to other libs
				refs=$(otool -XL "${d}" | \
					sed -e '1d' -e 's/^\t//' | \
					grep "^libboost_" | \
					cut -f1 -d' ')
				local r
				for r in ${refs}; do
					ebegin "    correcting reference to ${r}"
					install_name_tool -change \
						"${r}" \
						"${EPREFIX}/usr/lib/${r}" \
						"${d}"
					eend $?
				done
			fi
		done
	fi
}

pkg_preinst() {
	# /usr/include/boost and /usr/share/boostbook were symlinks to directories in older versions of Boost.
	local symlink
	for symlink in "${EROOT}usr/include/boost" "${EROOT}usr/share/boostbook"; do
		if [[ -L ${symlink} ]]; then
			rm -f "${symlink}" || die
		fi
	done
}

pkg_postinst() {
	if use mpi && use python; then
		python_byte-compile_modules boost
	fi
}

pkg_postrm() {
	if use mpi && use python; then
		python_clean_byte-compiled_modules boost
	fi
}
