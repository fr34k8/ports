# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
GCONF_DEBUG="no"
GNOME2_LA_PUNT="yes"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="*-jython *-pypy-*"

inherit autotools eutils gnome2 multilib python virtualx

DESCRIPTION="GLib's GObject library bindings for Python"
HOMEPAGE="http://www.pygtk.org/"

LICENSE="LGPL-2.1+"
SLOT="2"
KEYWORDS="*"
IUSE="examples libffi test"

COMMON_DEPEND=">=dev-libs/glib-2.24.0:2
	libffi? ( virtual/libffi:= )"
DEPEND="${COMMON_DEPEND}
	dev-util/gtk-doc-am
	virtual/pkgconfig
	test? (
		media-fonts/font-cursor-misc
		media-fonts/font-misc-misc )"
RDEPEND="${COMMON_DEPEND}
	!<dev-python/pygtk-2.23"

pkg_setup() {
	python_pkg_setup

	if [[ "${MERGE_TYPE}" != "buildonly" ]] && has_version "<dev-python/pygobject-2.28.6-r1000"; then
		delete_old_symlinks() {
			rm -f "${EROOT}$(python_get_sitedir)/pygtk.pth" || return
			rm -f "${EROOT}$(python_get_sitedir)/pygtk.py" || return
		}
		python_execute_function -q delete_old_symlinks
	fi
}

src_prepare() {
	# Fix FHS compliance, see upstream bug #535524
	epatch "${FILESDIR}/${PN}-2.28.3-fix-codegen-location.patch"

	# Do not build tests if unneeded, bug #226345
	epatch "${FILESDIR}/${PN}-2.28.3-make_check.patch"

	# Disable tests that fail
	epatch "${FILESDIR}/${P}-disable-failing-tests.patch"

	# Disable introspection tests when we build with --disable-introspection
	epatch "${FILESDIR}/${P}-tests-no-introspection.patch"

	# Fix warning spam
	epatch "${FILESDIR}/${P}-set_qdata.patch"
	epatch "${FILESDIR}/${P}-gio-types-2.32.patch"

	# Fix glib-2.36 compatibility, bug #486602
	epatch "${FILESDIR}/${P}-glib-2.36-class_init.patch"

	# Support Python 3.
	epatch "${FILESDIR}/${P}-python-3.patch"
	epatch "${FILESDIR}/${P}-python-3-codegen.patch"
	sed -e "s/print datetime.date.today()/print(datetime.date.today())/" -i docs/Makefile.am

	sed \
		-e "s/AM_CONFIG_HEADER/AC_CONFIG_HEADERS/" \
		-e "/AM_PROG_CC_STDC/d" \
		-i configure.ac || die

	eautoreconf
	gnome2_src_prepare
	python_clean_py-compile_files

	python_copy_sources
}

src_configure() {
	DOCS="AUTHORS ChangeLog* NEWS README"
	# --disable-introspection and --disable-cairo because we use pygobject:3
	# for introspection support
	G2CONF="${G2CONF}
		--disable-introspection
		--disable-cairo
		$(use_with libffi ffi)"

	configuration() {
		PYTHON="$(PYTHON)" gnome2_src_configure
	}
	python_execute_function -s configuration
}

src_compile() {
	python_execute_function -d -s
}

src_test() {
	unset DBUS_SESSION_BUS_ADDRESS
	local -x GIO_USE_VFS="local" # prevents odd issues with deleting ${T}/.gvfs

	testing() {
		Xemake -j1 check PYTHON="$(PYTHON -a)" XDG_CACHE_HOME="${T}/${PYTHON_ABI}"
	}
	python_execute_function -s testing
}

src_install() {
	installation() {
		GNOME2_DESTDIR="${T}/images/${PYTHON_ABI}/" gnome2_src_install
		ln -fs $(python_get_sitedir)/gtk-2.0/codegen/codegen.py "${T}/images/${PYTHON_ABI}${EPREFIX}/usr/bin/pygobject-codegen-2.0"

		if [[ "$(python_get_version -l --major)" == "3" ]]; then
			rm -f "${T}/images/${PYTHON_ABI}${EPREFIX}/usr/$(get_libdir)/pkgconfig/pygobject-2.0.pc"
		fi
	}
	python_execute_function -s installation
	python_merge_intermediate_installation_images "${T}/images"

	python_clean_installation_image

	if use examples; then
		insinto /usr/share/doc/${PF}
		doins -r examples
	fi
}

pkg_postinst() {
	python_mod_optimize glib gobject gtk-2.0 pygtk.py
}

pkg_postrm() {
	python_mod_cleanup glib gobject gtk-2.0 pygtk.py
}
