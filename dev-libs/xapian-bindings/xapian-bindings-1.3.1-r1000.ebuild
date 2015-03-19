# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_DEPEND="python? ( <<[threads]>> )"
PYTHON_MULTIPLE_ABIS="1"
# Support for Python 3 is incomplete. 'import xapian' faileth with TypeError.
# http://trac.xapian.org/ticket/346
PYTHON_RESTRICTED_ABIS="3.* *-jython *-pypy-*"

USE_PHP="php5-4 php5-5 php5-6"

PHP_EXT_NAME="xapian"
PHP_EXT_INI="yes"
PHP_EXT_OPTIONAL_USE="php"

inherit java-pkg-opt-2 mono-env php-ext-source-r2 python

DESCRIPTION="SWIG and JNI bindings for Xapian"
HOMEPAGE="http://www.xapian.org/"
SRC_URI="http://oligarchy.co.uk/xapian/${PV}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~*"
IUSE="java lua mono perl php python ruby tcl"
REQUIRED_USE="|| ( java lua mono perl php python ruby tcl )"

RDEPEND="=dev-libs/xapian-${PV}*
	lua? ( >=dev-lang/lua-5.1 )
	mono? ( dev-lang/mono )
	perl? ( dev-lang/perl:= )
	ruby? ( dev-lang/ruby )
	tcl? ( >=dev-lang/tcl-8.1:= )"
DEPEND="${RDEPEND}
	java? ( >=virtual/jdk-1.3 )"
RDEPEND+="
	java? ( >=virtual/jre-1.3 )"

pkg_setup() {
	java-pkg-opt-2_pkg_setup

	if use mono; then
		mono-env_pkg_setup
	fi

	if use python; then
		python_pkg_setup
	fi
}

src_unpack() {
	default
}

src_prepare() {
	java-pkg-opt-2_src_prepare

	if use python; then
		sed \
			-e 's:\(^pkgpylib_DATA = xapian/__init__.py\).*:\1:' \
			-e 's|\(^xapian/__init__.py: modern/xapian.py\)|\1 xapian/_xapian$(PYTHON_SO)|' \
			-i python/Makefile.in || die "sed failed"
	fi
}

src_configure() {
	if use java; then
		CXXFLAGS+="${CXXFLAGS:+ }$(java-pkg_get-jni-cflags)"
	fi

	if use lua; then
		local LUA_LIB
		export LUA_LIB="$(pkg-config --variable=INSTALL_CMOD lua)"
	fi

	if use perl; then
		local PERL_ARCH PERL_LIB
		export PERL_ARCH="$(perl -MConfig -e 'print $Config{installvendorarch}')"
		export PERL_LIB="$(perl -MConfig -e 'print $Config{installvendorlib}')"
	fi

	econf \
		$(use_with java) \
		$(use_with lua) \
		$(use_with mono csharp) \
		$(use_with perl) \
		$(use_with php) \
		$(use_with python) \
		$(use_with ruby) \
		$(use_with tcl)

	# PHP and Python bindings are built/tested/installed manually.
	sed -e "/SUBDIRS =/s/ php//" -i Makefile || die "sed failed"
	sed -e "/SUBDIRS =/s/ python//" -i Makefile || die "sed failed"
}

src_compile() {
	default

	if use php; then
		local php_slot
		for php_slot in $(php_get_slots); do
			cp -r php php-${php_slot}
			emake -C php-${php_slot} \
				PHP="${EPREFIX}/usr/$(get_libdir)/${php_slot}/bin/php" \
				PHP_CONFIG="${EPREFIX}/usr/$(get_libdir)/${php_slot}/bin/php-config" \
				PHP_EXTENSION_DIR="$("${EPREFIX}/usr/$(get_libdir)/${php_slot}/bin/php-config" --extension-dir)" \
				PHP_INC="$("${EPREFIX}/usr/$(get_libdir)/${php_slot}/bin/php-config" --includes)"
		done
	fi

	if use python; then
		python_copy_sources python
		building() {
			emake \
				PYTHON="$(PYTHON)" \
				PYTHON_INC="$(python_get_includedir)" \
				PYTHON_LIB="$(python_get_libdir)" \
				PYTHON_SO="$("$(PYTHON)" -c 'import distutils.sysconfig; print(distutils.sysconfig.get_config_vars("SO")[0])')" \
				pkgpylibdir="$(python_get_sitedir)/xapian"
		}
		python_execute_function -s --source-dir python building
	fi
}

src_test() {
	default

	if use php; then
		local php_slot
		for php_slot in $(php_get_slots); do
			emake -C php-${php_slot} \
				PHP="${EPREFIX}/usr/$(get_libdir)/${php_slot}/bin/php" \
				PHP_CONFIG="${EPREFIX}/usr/$(get_libdir)/${php_slot}/bin/php-config" \
				PHP_EXTENSION_DIR="$("${EPREFIX}/usr/$(get_libdir)/${php_slot}/bin/php-config" --extension-dir)" \
				PHP_INC="$("${EPREFIX}/usr/$(get_libdir)/${php_slot}/bin/php-config" --includes)" \
				check
		done
	fi

	if use python; then
		testing() {
			emake \
				PYTHON="$(PYTHON)" \
				PYTHON_INC="$(python_get_includedir)" \
				PYTHON_LIB="$(python_get_libdir)" \
				PYTHON_SO="$("$(PYTHON)" -c 'import distutils.sysconfig; print(distutils.sysconfig.get_config_vars("SO")[0])')" \
				pkgpylibdir="$(python_get_sitedir)/xapian" \
				VERBOSE="1" \
				check
		}
		python_execute_function -s --source-dir python testing
	fi
}

src_install () {
	emake DESTDIR="${D}" install

	if use java; then
		java-pkg_dojar java/built/xapian_jni.jar
		# TODO: Make the build system not install this file.
		java-pkg_doso "${ED}/${S}/java/built/libxapian_jni.so"
		rm "${ED}/${S}/java/built/libxapian_jni.so"
		rmdir -p "${ED}/${S}/java/built"
		rmdir -p "${ED}/${S}/java/native"
	fi

	if use php; then
		local php_slot
		for php_slot in $(php_get_slots); do
			emake -C php-${php_slot} \
				DESTDIR="${D}" \
				PHP="${EPREFIX}/usr/$(get_libdir)/${php_slot}/bin/php" \
				PHP_CONFIG="${EPREFIX}/usr/$(get_libdir)/${php_slot}/bin/php-config" \
				PHP_EXTENSION_DIR="$("${EPREFIX}/usr/$(get_libdir)/${php_slot}/bin/php-config" --extension-dir)" \
				PHP_INC="$("${EPREFIX}/usr/$(get_libdir)/${php_slot}/bin/php-config" --includes)" \
				install
		done

		php-ext-source-r2_createinifiles
	fi

	if use python; then
		installation() {
			emake \
				DESTDIR="${D}" \
				PYTHON="$(PYTHON)" \
				PYTHON_INC="$(python_get_includedir)" \
				PYTHON_LIB="$(python_get_libdir)" \
				PYTHON_SO="$("$(PYTHON)" -c 'import distutils.sysconfig; print(distutils.sysconfig.get_config_vars("SO")[0])')" \
				pkgpylibdir="$(python_get_sitedir)/xapian" \
				install
		}
		python_execute_function -s --source-dir python installation
	fi

	# This directory is created in some combinations of USE flags.
	if [[ -d "${ED}usr/share/doc/xapian-bindings" ]]; then
		mv "${ED}usr/share/doc/xapian-bindings" "${ED}usr/share/doc/${PF}" || die "mv failed"
	fi

	dodoc AUTHORS HACKING NEWS TODO README
}

pkg_postinst() {
	if use python; then
		python_mod_optimize xapian
	fi
}

pkg_postrm() {
	if use python; then
		python_mod_cleanup xapian
	fi
}
