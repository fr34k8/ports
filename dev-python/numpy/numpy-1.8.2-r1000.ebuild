# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="*-jython *-pypy-*"

FORTRAN_NEEDED="lapack"

inherit distutils eutils flag-o-matic fortran-2 multilib toolchain-funcs

MY_P="${PN}-${PV/_/}"
DOC_PV="1.8.1"
DOC_P="${PN}-${DOC_PV}"

DESCRIPTION="Fast array and numerical python library"
HOMEPAGE="http://www.numpy.org/ https://github.com/numpy/numpy https://pypi.python.org/pypi/numpy"
SRC_URI="mirror://sourceforge/numpy/${MY_P}.tar.gz
	doc? (
		http://docs.scipy.org/doc/${DOC_P}/${PN}-html-${DOC_PV}.zip
		http://docs.scipy.org/doc/${DOC_P}/${PN}-ref-${DOC_PV}.pdf
		http://docs.scipy.org/doc/${DOC_P}/${PN}-user-${DOC_PV}.pdf
	)"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="doc lapack test"

RDEPEND="
	$(python_abi_depend dev-python/setuptools)
	lapack? ( virtual/cblas virtual/lapack )"
DEPEND="${RDEPEND}
	>=dev-python/cython-0.19
	lapack? ( virtual/pkgconfig )
	test? ( $(python_abi_depend dev-python/nose) )"

S="${WORKDIR}/${MY_P}"

PYTHON_CFLAGS=("* + -fno-strict-aliasing")

DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES="1"
DOCS="COMPATIBILITY DEV_README.txt THANKS.txt"

pkg_setup() {
	fortran-2_pkg_setup
	python_pkg_setup
}

src_unpack() {
	unpack ${MY_P}.tar.gz
	if use doc; then
		unzip -qo "${DISTDIR}/${PN}-html-${DOC_PV}.zip" -d html || die
	fi
}

pc_incdir() {
	$(tc-getPKG_CONFIG) --cflags-only-I $@ | \
		sed -e 's/^-I//' -e 's/[ ]*-I/:/g' -e 's/[ ]*$//' -e 's|^:||'
}

pc_libdir() {
	$(tc-getPKG_CONFIG) --libs-only-L $@ | \
		sed -e 's/^-L//' -e 's/[ ]*-L/:/g' -e 's/[ ]*$//' -e 's|^:||'
}

pc_libs() {
	$(tc-getPKG_CONFIG) --libs-only-l $@ | \
		sed -e 's/[ ]-l*\(pthread\|m\)\([ ]\|$\)//g' \
		-e 's/^-l//' -e 's/[ ]*-l/,/g' -e 's/[ ]*$//' \
		| tr ',' '\n' | sort -u | tr '\n' ',' | sed -e 's|,$||'
}

src_prepare() {
	epatch "${FILESDIR}/${PN}-1.8.1-system_info.patch"

	# Support Python 3.1.
	sed -e "/sys.version_info/s/(3, 2)/(3, 1)/" -i setup.py

	if use lapack; then
		append-ldflags "$($(tc-getPKG_CONFIG) --libs-only-other cblas lapack)"
		local libdir="${EPREFIX}"/usr/$(get_libdir)
		# make sure _dotblas.so gets built
		sed -i -e '/NO_ATLAS_INFO/,+1d' numpy/core/setup.py || die
		cat >> site.cfg <<-EOF
			[blas]
			include_dirs = $(pc_incdir cblas)
			library_dirs = $(pc_libdir cblas blas):${libdir}
			blas_libs = $(pc_libs cblas blas)
			[lapack]
			library_dirs = $(pc_libdir lapack):${libdir}
			lapack_libs = $(pc_libs lapack)
		EOF
	else
		export {ATLAS,PTATLAS,BLAS,LAPACK,MKL}=None
	fi

	export CC="$(tc-getCC) ${CFLAGS}"

	# See progress in http://projects.scipy.org/scipy/numpy/ticket/573
	# with the subtle difference that we don't want to break Darwin where
	# -shared is not a valid linker argument
	if [[ ${CHOST} != *-darwin* ]]; then
		append-ldflags -shared
	fi

	# only one fortran to link with:
	# linking with cblas and lapack library will force
	# autodetecting and linking to all available fortran compilers
	if use lapack; then
		NUMPY_FCONFIG="config_fc --noopt --noarch"
		# workaround bug 335908
		[[ $(tc-getFC) == *gfortran* ]] && NUMPY_FCONFIG+=" --fcompiler=gnu95"
	fi

	# Disable versioning of f2py script.
	sed -e "s/f2py_exe = 'f2py'+os.path.basename(sys.executable)\[6:\]$/f2py_exe = 'f2py'/" -i numpy/f2py/setup.py || die

	distutils_src_prepare

	preparation() {
		# Regenerate Cython-generated files.
		pushd numpy/random/mtrand > /dev/null
		python_execute "$(PYTHON)" generate_mtrand_c.py || die "Cythonization of numpy/random/mtrand/mtrand.pyx failed"
		popd > /dev/null
	}
	python_execute_function -s preparation
}

src_compile() {
	distutils_src_compile ${NUMPY_FCONFIG}
}

src_test() {
	local -x FFLAGS="${FFLAGS} -fPIC"

	testing() {
		python_execute "$(PYTHON)" setup.py ${NUMPY_FCONFIG} install --root="${T}/tests-${PYTHON_ABI}" || die "Installation for tests failed with $(python_get_implementation_and_version)"
		pushd "${T}/tests-${PYTHON_ABI}" > /dev/null || die
		python_execute PYTHONPATH="${T}/tests-${PYTHON_ABI}${EPREFIX}$(python_get_sitedir)" "$(PYTHON)" -c "import numpy, sys; sys.exit(not numpy.test(label='full', verbose=3).wasSuccessful())" || return
		popd > /dev/null || die
	}
	python_execute_function -s testing
}

src_install() {
	distutils_src_install ${NUMPY_FCONFIG}

	(
		docinto f2py
		dodoc numpy/f2py/docs/*.txt
	)
	doman numpy/f2py/f2py.1

	if use doc; then
		dohtml -r "${WORKDIR}/html/"
		dodoc "${DISTDIR}/${PN}"-{ref,user}-${DOC_PV}.pdf
	fi
}
