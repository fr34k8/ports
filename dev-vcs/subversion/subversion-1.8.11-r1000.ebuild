# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
GENTOO_DEPEND_ON_PERL="no"
PYTHON_DEPEND="ctypes-python? ( <<>> ) python? ( <<>> )"
if [[ "${PV}" == *_pre* ]]; then
	# autogen.sh calls gen-make.py.
	PYTHON_BDEPEND="<<>>"
else
	PYTHON_BDEPEND="test? ( <<>> )"
fi
PYTHON_ABI_TYPE="multiple"
PYTHON_RESTRICTED_ABIS="3.* *-jython *-pypy"
if [[ "${PV}" != *_pre* ]]; then
	WANT_AUTOMAKE="none"
fi

inherit $([[ "${PV}" != *_pre* ]] && echo autotools) bash-completion-r1 db-use depend.apache eutils flag-o-matic java-pkg-opt-2 libtool multilib perl-module python $([[ "${PV}" == *_pre* ]] && echo subversion)

DESCRIPTION="Advanced version control system"
HOMEPAGE="http://subversion.apache.org/"
if [[ "${PV}" == *_pre* ]]; then
	SRC_URI=""
else
	SRC_URI="mirror://apache/${PN}/${P}.tar.bz2"
fi

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="apache2 berkdb ctypes-python debug doc +dso extras gnome-keyring +http java kde +magic nls perl python ruby sasl static-libs test"
REQUIRED_USE="extras? ( python ) test? ( http? ( apache2 ) )"

CDEPEND=">=dev-db/sqlite-3.7.12
	>=dev-libs/apr-1.3:1
	>=dev-libs/apr-util-1.3:1
	dev-libs/expat
	sys-libs/zlib:0=
	berkdb? ( >=sys-libs/db-4:= )
	gnome-keyring? ( dev-libs/glib:2 sys-apps/dbus gnome-base/libgnome-keyring )
	http? ( >=net-libs/serf-1.2.1 )
	kde? ( dev-qt/qtcore:4 dev-qt/qtdbus:4 dev-qt/qtgui:4 sys-apps/dbus kde-base/kdelibs:4 )
	magic? ( sys-apps/file )
	perl? ( dev-lang/perl:= )
	ruby? ( >=dev-lang/ruby-1.8.2 )
	sasl? ( dev-libs/cyrus-sasl )"
RDEPEND="${CDEPEND}
	apache2? ( www-servers/apache[apache2_modules_dav] )
	extras? ( =dev-lang/python-2* )
	java? ( >=virtual/jre-1.5 )
	kde? ( || ( kde-apps/kwalletd:4 kde-base/kwalletd ) )
	nls? ( virtual/libintl )
	perl? ( dev-perl/URI )"
DEPEND="${CDEPEND}
	!!<sys-apps/sandbox-1.6
	ctypes-python? ( $(python_abi_depend dev-python/ctypesgen) )
	doc? ( app-doc/doxygen )
	gnome-keyring? ( virtual/pkgconfig )
	http? ( virtual/pkgconfig )
	java? ( >=virtual/jdk-1.5 )
	kde? ( virtual/pkgconfig )
	nls? ( sys-devel/gettext )
$(if [[ "${PV}" == *_pre* ]]; then
	echo "	perl? ( >=dev-lang/swig-1.3.24 )"
	echo "	python? ( >=dev-lang/swig-1.3.24 )"
	echo "	ruby? ( >=dev-lang/swig-1.3.24 )"
fi)
	test? ( http? ( || (
		=www-servers/apache-2.4*[apache2_modules_auth_basic,apache2_modules_authn_core,apache2_modules_authn_file,apache2_modules_authz_core,apache2_modules_authz_user,apache2_modules_dav,apache2_modules_log_config,apache2_modules_unixd]
		=www-servers/apache-2.2*[apache2_modules_auth_basic,apache2_modules_authn_file,apache2_modules_dav,apache2_modules_log_config]
	) ) )"

want_apache

if [[ "${PV}" == *_pre* ]]; then
	ESVN_PROJECT="subversion"
	ESVN_REPO_URI="https://svn.apache.org/repos/asf/subversion/trunk"
	ESVN_REVISION="${PV#*_pre}"
fi

PYTHON_CFLAGS=("2.* + -fno-strict-aliasing")

print() {
	local blue color green normal red

	if [[ "${NOCOLOR:-false}" =~ ^(false|no)$ ]]; then
		red=$'\e[1;31m'
		green=$'\e[1;32m'
		blue=$'\e[1;34m'
		normal=$'\e[0m'
	fi

	while (($#)); do
		case "$1" in
			--red)
				color="${red}"
				;;
			--green)
				color="${green}"
				;;
			--blue)
				color="${blue}"
				;;
			--)
				shift
				break
				;;
			-*)
				die "${FUNCNAME}(): Unrecognized option '$1'"
				;;
			*)
				break
				;;
		esac
		shift
	done

	echo " ${green}*${normal} ${color}$@${normal}"
}

pkg_setup() {
	if use berkdb; then
		einfo
		if [[ -z "${SVN_BDB_VERSION}" ]]; then
			SVN_BDB_VERSION="$(db_ver_to_slot "$(db_findver sys-libs/db 2>/dev/null)")"
			einfo "SVN_BDB_VERSION variable isn't set. You can set it to enforce using of specific version of Berkeley DB."
		fi
		einfo "Using: Berkeley DB ${SVN_BDB_VERSION}"
		einfo

		local apu_bdb_version="$(scanelf -nq "${EROOT}usr/$(get_libdir)/libaprutil-1$(get_libname 0)" | grep -Eo "libdb-[[:digit:]]+\.[[:digit:]]+" | sed -e "s/libdb-\(.*\)/\1/")"
		if [[ -n "${apu_bdb_version}" && "${SVN_BDB_VERSION}" != "${apu_bdb_version}" ]]; then
			eerror "APR-Util is linked against Berkeley DB ${apu_bdb_version}, but you are trying"
			eerror "to build Subversion with support for Berkeley DB ${SVN_BDB_VERSION}."
			eerror "Rebuild dev-libs/apr-util or set SVN_BDB_VERSION=\"${apu_bdb_version}\"."
			eerror "Aborting to avoid possible run-time crashes."
			die "Berkeley DB version mismatch"
		fi
	fi

	depend.apache_pkg_setup

	java-pkg-opt-2_pkg_setup

	if [[ "${PV}" == *_pre* ]] || use ctypes-python || use python || use test; then
		python_pkg_setup
	fi

	if use test; then
		print
		print --red "************************************************************************************************"
		print
		print "NOTES ABOUT TESTS"
		print
		print "You can set the following variables to enable testing of some features and configure testing:"
		if use http; then
			print "  SVN_TEST_APACHE_PORT=integer          - Set Apache port number (Default value: 62208)"
		fi
		print "  SVN_TEST_SVNSERVE_PORT=integer        - Set svnserve port number (Default value: 62209)"
		print "  SVN_TEST_FSFS_MEMCACHED=1             - Enable using of Memcached for FSFS repositories"
		print "  SVN_TEST_FSFS_MEMCACHED_PORT=integer  - Set Memcached port number (Default value: 62210)"
		print "  SVN_TEST_FSFS_SHARDING=integer        - Enable sharding of FSFS repositories and set default shard size for FSFS repositories"
		print "  SVN_TEST_FSFS_PACKING=1               - Enable packing of FSFS repositories"
		print "                                          (SVN_TEST_FSFS_PACKING requires SVN_TEST_FSFS_SHARDING)"
#		if use sasl; then
#			print "  SVN_TEST_SASL=1                       - Enable SASL authentication"
#		fi
		if use ctypes-python || use java || use perl || use python || use ruby; then
			print "  SVN_TEST_BINDINGS=1                   - Enable testing of bindings"
		fi
		if use java || use perl || use python || use ruby; then
			print "                                          (Testing of bindings requires ${CATEGORY}/${PF})"
		fi
		if use java; then
			print "                                          (Testing of JavaHL library requires dev-java/junit:4)"
		fi
		print
		print --red "************************************************************************************************"
		print

		if [[ -n "${SVN_TEST_APACHE_PORT}" ]] && ! ([[ "$((${SVN_TEST_APACHE_PORT}))" == "${SVN_TEST_APACHE_PORT}" ]]) &>/dev/null; then
			die "Value of SVN_TEST_APACHE_PORT must be an integer"
		fi

		if [[ -n "${SVN_TEST_SVNSERVE_PORT}" ]] && ! ([[ "$((${SVN_TEST_SVNSERVE_PORT}))" == "${SVN_TEST_SVNSERVE_PORT}" ]]) &>/dev/null; then
			die "Value of SVN_TEST_SVNSERVE_PORT must be an integer"
		fi

		if [[ -n "${SVN_TEST_FSFS_MEMCACHED}" ]] && ! has_version net-misc/memcached; then
			die "net-misc/memcached must be installed"
		fi
		if [[ -n "${SVN_TEST_FSFS_MEMCACHED_PORT}" ]] && ! ([[ "$((${SVN_TEST_FSFS_MEMCACHED_PORT}))" == "${SVN_TEST_FSFS_MEMCACHED_PORT}" ]]) &>/dev/null; then
			die "Value of SVN_TEST_FSFS_MEMCACHED_PORT must be an integer"
		fi
		if [[ -n "${SVN_TEST_FSFS_SHARDING}" ]] && ! ([[ "$((${SVN_TEST_FSFS_SHARDING}))" == "${SVN_TEST_FSFS_SHARDING}" ]]) &>/dev/null; then
			die "Value of SVN_TEST_FSFS_SHARDING must be an integer"
		fi
		if [[ -n "${SVN_TEST_FSFS_PACKING}" && -z "${SVN_TEST_FSFS_SHARDING}" ]]; then
			die "SVN_TEST_FSFS_PACKING requires SVN_TEST_FSFS_SHARDING"
		fi

		if [[ -n "${SVN_TEST_BINDINGS}" ]]; then
			if { use java || use perl || use python || use ruby; } && ! has_version "=${CATEGORY}/${PF}"; then
				die "${CATEGORY}/${PF} must be installed"
			fi
			if use java && ! has_version dev-java/junit:4; then
				die "dev-java/junit:4 must be installed"
			fi
		fi
	fi

	if use debug; then
		append-cppflags -DSVN_DEBUG -DAP_DEBUG
	fi
}

src_prepare() {
	epatch "${FILESDIR}/${PN}-1.8.5-perl_CFLAGS.patch"

	if ! use test; then
		sed -i \
			-e "s/\(BUILD_RULES=.*\) bdb-test\(.*\)/\1\2/g" \
			-e "s/\(BUILD_RULES=.*\) test\(.*\)/\1\2/g" configure.ac
	fi

	sed -e "/SWIG_PY_INCLUDES=/s/\$ac_cv_python_includes/\\\\\$(PYTHON_INCLUDES)/" -i build/ac-macros/swig.m4 || die "sed failed"

	if [[ "${PV}" == *_pre* ]]; then
		./autogen.sh || die "autogen.sh failed"
	else
		eautoconf
	fi

	elibtoolize

	sed -e "s/libsvn_swig_py-1\.la/libsvn_swig_py-\$(PYTHON_VERSION)-1.la/" -i build-outputs.mk || die "sed failed"
}

src_configure() {
	local myconf=()

	if use python || use perl || use ruby; then
		myconf+=("--with-swig")
	else
		myconf+=("--without-swig")
	fi

	if use java; then
		local JAVAC_FLAGS="$(java-pkg_javac-args) -encoding iso8859-1"
		export JAVAC_FLAGS

		if use test && [[ -n "${SVN_TEST_BINDINGS}" ]]; then
			myconf+=("--with-junit=${EPREFIX}/usr/share/junit-4/lib/junit.jar")
		else
			myconf+=("--without-junit")
		fi
	fi

	econf --libdir="${EPREFIX}/usr/$(get_libdir)" \
		$(use_with apache2 apache-libexecdir) \
		$(use_with apache2 apxs "${APXS}") \
		$(use_with berkdb berkeley-db "db.h:${EPREFIX}/usr/include/db${SVN_BDB_VERSION}::db-${SVN_BDB_VERSION}") \
		$(use_with ctypes-python ctypesgen "${EPREFIX}/usr") \
		$(use_enable dso runtime-module-search) \
		$(use_with gnome-keyring) \
		$(use_with http serf) \
		$(use_enable java javahl) \
		$(use_with java jdk "${JAVA_HOME}") \
		$(use_with kde kwallet) \
		$(use_with magic libmagic) \
		$(use_enable nls) \
		$(use_with sasl) \
		$(use_enable static-libs static) \
		"${myconf[@]}" \
		--with-apr="${EPREFIX}/usr/bin/apr-1-config" \
		--with-apr-util="${EPREFIX}/usr/bin/apu-1-config" \
		--enable-bdb6 \
		--enable-disallowing-of-undefined-references \
		--disable-experimental-libtool \
		--without-jikes \
		--enable-local-library-preloading \
		--disable-mod-activation \
		--with-sqlite="${EPREFIX}/usr"
}

src_compile() {
	print
	print "Building of core of Subversion"
	print
	emake local-all || die "Building of core of Subversion failed"

	if use ctypes-python; then
		print
		print "Building of Subversion Ctypes Python bindings"
		print
		python_copy_sources subversion/bindings/ctypes-python
		rm -fr subversion/bindings/ctypes-python
		ctypes_python_bindings_building() {
			rm -f subversion/bindings/ctypes-python
			ln -s ctypes-python-${PYTHON_ABI} subversion/bindings/ctypes-python
			emake ctypes-python
		}
		python_execute_function \
			--action-message 'Building of Subversion Ctypes Python bindings with $(python_get_implementation_and_version)' \
			--failure-message 'Building of Subversion Ctypes Python bindings with $(python_get_implementation_and_version) failed' \
			ctypes_python_bindings_building
	fi

	if use python; then
		print
		print "Building of Subversion SWIG Python bindings"
		print
		python_copy_sources subversion/bindings/swig/python
		rm -fr subversion/bindings/swig/python
		swig_python_bindings_building() {
			rm -f subversion/bindings/swig/python
			ln -s python-${PYTHON_ABI} subversion/bindings/swig/python
			emake \
				PYTHON_INCLUDES="-I${EPREFIX}$(python_get_includedir)" \
				PYTHON_VERSION="$(python_get_version)" \
				swig_pydir="${EPREFIX}$(python_get_sitedir)/libsvn" \
				swig_pydir_extra="${EPREFIX}$(python_get_sitedir)/svn" \
				swig-py
		}
		python_execute_function \
			--action-message 'Building of Subversion SWIG Python bindings with $(python_get_implementation_and_version)' \
			--failure-message 'Building of Subversion SWIG Python bindings with $(python_get_implementation_and_version) failed' \
			swig_python_bindings_building
	fi

	if use perl; then
		print
		print "Building of Subversion SWIG Perl bindings"
		print
		emake -j1 swig-pl || die "Building of Subversion SWIG Perl bindings failed"
	fi

	if use ruby; then
		print
		print "Building of Subversion SWIG Ruby bindings"
		print
		emake swig-rb || die "Building of Subversion SWIG Ruby bindings failed"
	fi

	if use java; then
		print
		print "Building of Subversion JavaHL library"
		print
		emake -j1 javahl || die "Building of Subversion JavaHL library failed"
	fi

	if use doc; then
		print
		print "Building of Subversion HTML documentation"
		print
		doxygen doc/doxygen.conf || die "Building of Subversion HTML documentation failed"

		if use java; then
			print
			print "Building of Subversion JavaHL library HTML documentation"
			print
			emake doc-javahl || die "Building of Subversion JavaHL library HTML documentation failed"
		fi
	fi
}

create_apache_tests_configuration() {
	get_loadmodule_directive() {
		if [[ "$("${APACHE_BIN}" -l)" != *"mod_$1.c"* ]]; then
			echo "LoadModule $1_module \"${APACHE_MODULESDIR}/mod_$1$(get_libname)\""
		fi
	}
	get_loadmodule_directives() {
		if has_version "=www-servers/apache-2.4*"; then
			get_loadmodule_directive alias
			get_loadmodule_directive auth_basic
			get_loadmodule_directive authn_core
			get_loadmodule_directive authn_file
			get_loadmodule_directive authz_core
			get_loadmodule_directive authz_user
			get_loadmodule_directive dav
			get_loadmodule_directive log_config
			get_loadmodule_directive unixd
		else
			get_loadmodule_directive alias
			get_loadmodule_directive auth_basic
			get_loadmodule_directive authn_file
			get_loadmodule_directive dav
			get_loadmodule_directive log_config
		fi
	}

	mkdir -p "${T}/apache"
	cat << EOF > "${T}/apache/apache.conf"
$(get_loadmodule_directives)
LoadModule dav_svn_module "${S}/subversion/mod_dav_svn/.libs/mod_dav_svn$(get_libname)"
LoadModule authz_svn_module "${S}/subversion/mod_authz_svn/.libs/mod_authz_svn$(get_libname)"

User                $(id -un)
Group               $(id -gn)
Listen              localhost:${SVN_TEST_APACHE_PORT}
ServerName          localhost
ServerRoot          "${T}"
DocumentRoot        "${T}"
CoreDumpDirectory   "${T}"
PidFile             "${T}/apache.pid"
CustomLog           "${T}/apache/access_log" "%h %l %u %{%Y-%m-%dT%H:%M:%S}t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\""
CustomLog           "${T}/apache/svn_log" "%{%Y-%m-%dT%H:%M:%S}t %u %{SVN-REPOS-NAME}e %{SVN-ACTION}e" env=SVN-ACTION
ErrorLog            "${T}/apache/error_log"
LogLevel            Debug
MaxRequestsPerChild 0

<Directory />
	AllowOverride None
</Directory>

<Location /svn-test-work/repositories>
	DAV svn
	SVNParentPath "${S}/subversion/tests/cmdline/svn-test-work/repositories"
	AuthzSVNAccessFile "${S}/subversion/tests/cmdline/svn-test-work/authz"
	AuthType Basic
	AuthName "Subversion Repository"
	AuthUserFile "${T}/apache/users"
	Require valid-user
</Location>

<Location /svn-test-work/local_tmp/repos>
	DAV svn
	SVNPath "${S}/subversion/tests/cmdline/svn-test-work/local_tmp/repos"
	AuthzSVNAccessFile "${S}/subversion/tests/cmdline/svn-test-work/authz"
	AuthType Basic
	AuthName "Subversion Repository"
	AuthUserFile "${T}/apache/users"
	Require valid-user
</Location>

RedirectMatch permanent ^/svn-test-work/repositories/REDIRECT-PERM-(.*)\$ /svn-test-work/repositories/\$1
RedirectMatch           ^/svn-test-work/repositories/REDIRECT-TEMP-(.*)\$ /svn-test-work/repositories/\$1
EOF

	cat << EOF > "${T}/apache/users"
jrandom:xCGl35kV9oWCY
jconstant:xCGl35kV9oWCY
EOF
}

set_tests_variables() {
	if [[ "$1" == "local" ]]; then
		base_url="file://${S}/subversion/tests/cmdline"
		http_library=""
	fi
	if [[ "$1" == "svn" ]]; then
		base_url="svn://127.0.0.1:${SVN_TEST_SVNSERVE_PORT}"
		http_library=""
	fi
	if [[ "$1" == "serf" ]]; then
		base_url="http://127.0.0.1:${SVN_TEST_APACHE_PORT}"
		http_library="$1"
	fi
}

src_test() {
	if ! use test; then
		die "Invalid configuration"
	fi

	local fs_type fs_types ra_type ra_types options failed_tests

	fs_types="fsfs"
	use berkdb && fs_types+=" bdb"

	ra_types="local svn"
	use http && ra_types+=" serf"

	local pid_file
	for pid_file in svnserve.pid apache.pid memcached.pid; do
		rm -f "${T}/${pid_file}"
	done

	termination() {
		local die="$1" pid_file
		if [[ -n "${die}" ]]; then
			echo -e "\n\e[1;31mKilling of child processes...\e[0m\a" > /dev/tty
		fi
		for pid_file in svnserve.pid apache.pid memcached.pid; do
			if [[ -f "${T}/${pid_file}" ]]; then
				kill "$(<"${T}/${pid_file}")"
			fi
		done
		if [[ -n "${die}" ]]; then
			sleep 6
			die "Termination"
		fi
	}

	trap 'termination 1 &' SIGINT SIGTERM

	SVN_TEST_SVNSERVE_PORT="${SVN_TEST_SVNSERVE_PORT:-62209}"
	LC_ALL="C" subversion/svnserve/svnserve -dr "subversion/tests/cmdline" --listen-port "${SVN_TEST_SVNSERVE_PORT}" --log-file "${T}/svnserve.log" --pid-file "${T}/svnserve.pid"
	if use http; then
		SVN_TEST_APACHE_PORT="${SVN_TEST_APACHE_PORT:-62208}"
		create_apache_tests_configuration
		"${APACHE_BIN}" -f "${T}/apache/apache.conf"
	fi
	if [[ -n "${SVN_TEST_FSFS_MEMCACHED}" ]]; then
		SVN_TEST_FSFS_MEMCACHED_PORT="${SVN_TEST_FSFS_MEMCACHED_PORT:-62210}"
		sed -e "/\[memcached-servers\]/akey = 127.0.0.1:${SVN_TEST_FSFS_MEMCACHED_PORT}" -i subversion/tests/tests.conf
		memcached -dp "${SVN_TEST_FSFS_MEMCACHED_PORT}" -P "${T}/memcached.pid"
	fi
	if [[ -n "${SVN_TEST_FSFS_SHARDING}" ]]; then
		options+=" FSFS_SHARDING=${SVN_TEST_FSFS_SHARDING}"
	fi
	if [[ -n "${SVN_TEST_FSFS_PACKING}" ]]; then
		options+=" FSFS_PACKING=1"
	fi
#	if [[ -n "${SVN_TEST_SASL}" ]]; then
#		options+=" ENABLE_SASL=1"
#	fi

	sleep 6

	for ra_type in ${ra_types}; do
		for fs_type in ${fs_types}; do
			[[ "${ra_type}" == "local" && "${fs_type}" == "bdb" ]] && continue
			print
			print --blue "Testing of ra_${ra_type} + $(echo ${fs_type} | tr '[:lower:]' '[:upper:]')"
			print
			set_tests_variables ${ra_type}
			time emake check FS_TYPE="${fs_type}" BASE_URL="${base_url}" HTTP_LIBRARY="${http_library}" CLEANUP="1" ${options} || failed_tests="1"
			mv tests.log "${T}/tests-ra_${ra_type}-${fs_type}.log"
		done
	done
	unset base_url http_library
	termination
	trap - SIGINT SIGTERM

	if [[ -n "${SVN_TEST_BINDINGS}" ]]; then
		local swig_lingua swig_linguas
		local -A linguas

		if use ctypes-python; then
			print
			print --blue "Testing of Subversion Ctypes Python bindings"
			print
			ctypes_python_bindings_testing() {
				rm -f subversion/bindings/ctypes-python
				ln -s ctypes-python-${PYTHON_ABI} subversion/bindings/ctypes-python
				time emake check-ctypes-python || failed_tests="1"
			}
			python_execute_function \
				--action-message 'Testing of Subversion Ctypes Python bindings with $(python_get_implementation_and_version)' \
				--failure-message 'Testing of Subversion Ctypes Python bindings with $(python_get_implementation_and_version) failed' \
				ctypes_python_bindings_testing
		fi

		if use python; then
			print
			print --blue "Testing of Subversion SWIG Python bindings"
			print
			swig_python_bindings_testing() {
				rm -f subversion/bindings/swig/python
				ln -s python-${PYTHON_ABI} subversion/bindings/swig/python
				time emake PYTHON_VERSION="$(python_get_version)" check-swig-py || failed_tests="1"
			}
			python_execute_function \
				--action-message 'Testing of Subversion SWIG Python bindings with $(python_get_implementation_and_version)' \
				--failure-message 'Testing of Subversion SWIG Python bindings with $(python_get_implementation_and_version) failed' \
				swig_python_bindings_testing
		fi

		use perl && swig_linguas+=" pl"
		use ruby && swig_linguas+=" rb"

		linguas[pl]="Perl"
		linguas[rb]="Ruby"

		for swig_lingua in ${swig_linguas}; do
			print
			print --blue "Testing of Subversion SWIG ${linguas[${swig_lingua}]} bindings"
			print
			time emake check-swig-${swig_lingua} || failed_tests="1"
		done

		if use java; then
			print
			print --blue "Testing of Subversion JavaHL library"
			print
			time emake check-javahl || failed_tests="1"
		fi
	fi

	if [[ -n "${failed_tests}" ]]; then
		ewarn
		ewarn "\e[1;31mTests failed\e[0m"
		ewarn
	fi
}

src_install() {
	print
	print "Installation of core of Subversion"
	print
	emake -j1 DESTDIR="${D}" local-install || die "Installation of core of Subversion failed"

	if use ctypes-python; then
		print
		print "Installation of Subversion Ctypes Python bindings"
		print
		ctypes_python_bindings_installation() {
			rm -f subversion/bindings/ctypes-python
			ln -s ctypes-python-${PYTHON_ABI} subversion/bindings/ctypes-python
			emake DESTDIR="${D}" install-ctypes-python
		}
		python_execute_function \
			--action-message 'Installation of Subversion Ctypes Python bindings with $(python_get_implementation_and_version)' \
			--failure-message 'Installation of Subversion Ctypes Python bindings with $(python_get_implementation_and_version) failed' \
			ctypes_python_bindings_installation
	fi

	if use python; then
		print
		print "Installation of Subversion SWIG Python bindings"
		print
		swig_python_bindings_installation() {
			rm -f subversion/bindings/swig/python
			ln -s python-${PYTHON_ABI} subversion/bindings/swig/python
			emake -j1 \
				DESTDIR="${D}" \
				PYTHON_VERSION="$(python_get_version)" \
				swig_pydir="${EPREFIX}$(python_get_sitedir)/libsvn" \
				swig_pydir_extra="${EPREFIX}$(python_get_sitedir)/svn" \
				install-swig-py
		}
		python_execute_function \
			--action-message 'Installation of Subversion SWIG Python bindings with $(python_get_implementation_and_version)' \
			--failure-message 'Installation of Subversion SWIG Python bindings with $(python_get_implementation_and_version) failed' \
			swig_python_bindings_installation
	fi

	if use ctypes-python || use python; then
		python_clean_installation_image -q
	fi

	if use perl; then
		print
		print "Installation of Subversion SWIG Perl bindings"
		print
		emake -j1 DESTDIR="${D}" INSTALLDIRS="vendor" install-swig-pl || die "Installation of Subversion SWIG Perl bindings failed"
		perl_delete_localpod
		find "${ED}" "(" -name .packlist -o -name "*.bs" ")" -print0 | xargs -0 rm -fr
	fi

	if use ruby; then
		print
		print "Installation of Subversion SWIG Ruby bindings"
		print
		emake -j1 DESTDIR="${D}" install-swig-rb || die "Installation of Subversion SWIG Ruby bindings failed"
		find "${ED}usr/$(get_libdir)/ruby" "(" -name "*.a" -o -name "*.la" ")" -print0 | xargs -0 rm -f
	fi

	if use java; then
		print
		print "Installation of Subversion JavaHL library"
		print
		emake -j1 DESTDIR="${D}" install-javahl || die "Installation of Subversion JavaHL library failed"
		java-pkg_regso "${ED}"usr/$(get_libdir)/libsvnjavahl*$(get_libname)
		java-pkg_dojar "${ED}"usr/$(get_libdir)/svn-javahl/svn-javahl.jar
		rm -fr "${ED}"usr/$(get_libdir)/svn-javahl/*.jar
	fi

	# Install Apache module configuration.
	if use apache2; then
		mkdir -p "${D}${APACHE_MODULES_CONFDIR}"
		cat << EOF > "${D}${APACHE_MODULES_CONFDIR}"/47_mod_dav_svn.conf
<IfDefine SVN>
LoadModule dav_svn_module modules/mod_dav_svn$(get_libname)
<IfDefine SVN_AUTHZ>
LoadModule authz_svn_module modules/mod_authz_svn$(get_libname)
</IfDefine>

# Example configuration:
#<Location /svn/repos>
#	DAV svn
#	SVNPath /var/svn/repos
#	AuthType Basic
#	AuthName "Subversion repository"
#	AuthUserFile /var/svn/conf/svnusers
#	Require valid-user
#</Location>
</IfDefine>
EOF
	fi

	# Install Bash Completion, bug 43179.
	newbashcomp tools/client-side/bash_completion svn
	bashcomp_alias svn svn{admin,dumpfilter,look,sync,version}
	rm -f tools/client-side/bash_completion

	# Install svnserve init script and xinet.d configuration.
	newconfd "${FILESDIR}/svnserve.confd" svnserve
	newinitd "${FILESDIR}/svnserve.initd" svnserve
	insinto /etc/xinetd.d
	newins "${FILESDIR}/svnserve.xinetd" svnserve

	if ! use apache2; then
		sed \
			-e "s/USER:-apache/USER:-svn/" \
			-e "s/GROUP:-apache/GROUP:-svnusers/g" \
			-i "${ED}etc/init.d/svnserve"
	fi

	# Install documentation.
	dodoc CHANGES COMMITTERS README
	dodoc tools/xslt/svnindex.{css,xsl}
	rm -fr tools/xslt

	# Install extra files.
	if use extras; then
		print
		print "Installation of tools"
		print

		cat << EOF > 80subversion-extras
PATH="${EPREFIX}/usr/$(get_libdir)/subversion/bin"
ROOTPATH="${EPREFIX}/usr/$(get_libdir)/subversion/bin"
EOF
		doenvd 80subversion-extras

		emake DESTDIR="${D}" toolsdir="/usr/$(get_libdir)/subversion/bin" install-tools || die "Installation of tools failed"

		find tools "(" -name "*.bat" -o -name "*.in" -o -name "*.lo" -o -name "*.o" -o -name ".libs" ")" -print0 | xargs -0 rm -fr
		find tools/server-side -name "*.c" -print0 | xargs -0 rm -f
		rm -fr tools/client-side/svnmucc
		rm -fr tools/server-side/{svn-populate-node-origins-index,svnauthz-validate}*
		rm -fr tools/{buildbot,dev,diff,po}

		insinto /usr/share/${PN}
		doins -r tools

		python_convert_shebangs -r 2 "${ED}usr/share/${PN}"
	fi

	if use doc; then
		print
		print "Installation of Subversion HTML documentation"
		print
		dohtml -r doc/doxygen/html/* || die "Installation of Subversion HTML documentation failed"

#		if use ruby; then
#			emake DESTDIR="${D}" install-swig-rb-doc
#		fi

		if use java; then
			java-pkg_dojavadoc doc/javadoc
		fi
	fi

	rm -f "${ED}usr/$(get_libdir)/"{libsvn_auth_*,libsvn_swig_*,libsvnjavahl}-1.{a,la}
	rm -f "${ED}usr/share/subversion/"**/*.la
	if ! use static-libs; then
		find "${ED}" -name "*.la" -print0 | xargs -0 rm -f
	fi
}

pkg_preinst() {
	# Compare versions of Berkeley DB, bug 122877.
	if use berkdb && [[ -f "${EROOT}usr/bin/svn" ]]; then
		OLD_BDB_VERSION="$(scanelf -nq "${EROOT}usr/$(get_libdir)/libsvn_subr-1$(get_libname 0)" | grep -Eo "libdb-[[:digit:]]+\.[[:digit:]]+" | sed -e "s/libdb-\(.*\)/\1/")"
		NEW_BDB_VERSION="$(scanelf -nq "${ED}usr/$(get_libdir)/libsvn_subr-1$(get_libname 0)" | grep -Eo "libdb-[[:digit:]]+\.[[:digit:]]+" | sed -e "s/libdb-\(.*\)/\1/")"
		if [[ "${OLD_BDB_VERSION}" != "${NEW_BDB_VERSION}" ]]; then
			CHANGED_BDB_VERSION="1"
		fi
	fi
}

pkg_postinst() {
	if use ctypes-python || use python; then
		python_byte-compile_modules $(use ctypes-python && echo csvn) $(use python && echo libsvn svn)
	fi

	if use extras; then
		elog "If you intend to use hot-backup.py, you can specify the number of"
		elog "backups to keep per repository by specifying an environment variable."
		elog "If you want to keep e.g. 2 backups, do the following:"
		elog "echo '# hot-backup.py: Keep that many repository backups around' > /etc/env.d/80subversion"
		elog "echo 'SVN_HOTBACKUP_BACKUPS_NUMBER=2' >> /etc/env.d/80subversion"
		elog
	fi

	elog "Subversion contains support for the use of Memcached"
	elog "to cache data of FSFS repositories."
	elog "You should install \"net-misc/memcached\", start memcached"
	elog "and configure your FSFS repositories, if you want to use this feature."
	elog "See the documentation for details."
	elog

	if [[ -n "${CHANGED_BDB_VERSION}" ]]; then
		ewarn "You upgraded from an older version of Berkeley DB and may experience"
		ewarn "problems with your repository. Run the following commands as root to fix it:"
		ewarn "    db4_recover -h \${repository_path}"
		ewarn "    chown -Rf apache:apache \${repository_path}"
	fi
}

pkg_postrm() {
	if use ctypes-python || use python; then
		python_clean_byte-compiled_modules $(use ctypes-python && echo csvn) $(use python && echo libsvn svn)
	fi
}

pkg_config() {
	elog "Read \"Version Control With Subversion\" book:"
	elog "http://svnbook.red-bean.com/"
}
