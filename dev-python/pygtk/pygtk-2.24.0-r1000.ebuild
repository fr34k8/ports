# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
GCONF_DEBUG="no"
GNOME_TARBALL_SUFFIX="bz2"

PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.* *-jython *-pypy-*"
PYTHON_EXPORT_PHASE_FUNCTIONS="1"

inherit autotools eutils flag-o-matic gnome2 python virtualx

DESCRIPTION="GTK+2 bindings for Python"
HOMEPAGE="http://www.pygtk.org/"

LICENSE="LGPL-2.1"
SLOT="2"
KEYWORDS="*"
IUSE="doc examples test"

RDEPEND="
	>=dev-libs/glib-2.8:2
	>=x11-libs/pango-1.16
	>=dev-libs/atk-1.12
	>=x11-libs/gtk+-2.24:2
	$(python_abi_depend ">=dev-python/pycairo-1.0.2")
	$(python_abi_depend ">=dev-python/pygobject-2.21.3:2")
	$(python_abi_depend dev-python/numpy)
	>=gnome-base/libglade-2.5:2.0
"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	doc? (
		dev-libs/libxslt
		>=app-text/docbook-xsl-stylesheets-1.70.1 )
"

src_prepare() {
	# Fix declaration of codegen in .pc
	epatch "${FILESDIR}/${PN}-2.13.0-fix-codegen-location.patch"
	epatch "${FILESDIR}/${PN}-2.14.1-libdir-pc.patch"

	# Fix leaks of Pango objects.
	epatch "${FILESDIR}/${PN}-2.24.0-fix-leaks.patch"

	# Fix exit status of tests.
	epatch "${FILESDIR}/${P}-tests_result.patch"

	# Fix tests.
	# https://bugzilla.gnome.org/show_bug.cgi?id=709304
	epatch "${FILESDIR}/${P}-test_dialog.patch"

	# Disable installation of examples in wrong directory.
	sed -e "/^SUBDIRS =/s/ examples//" -i Makefile.am

	sed -e "s/AM_CONFIG_HEADER/AC_CONFIG_HEADERS/" -i configure.ac

	AT_M4DIR="m4" eautoreconf
	python_clean_py-compile_files

	python_copy_sources
}

src_configure() {
	use hppa && append-flags -ffunction-sections
	python_src_configure \
		$(use_enable doc docs) \
		--with-glade \
		--enable-thread
}

src_test() {
	# Let tests pass without permissions problems, bug #245103
	gnome2_environment_reset
	unset DBUS_SESSION_BUS_ADDRESS

	testing() {
		cd tests
		Xemake check-local
	}
	python_execute_function -s testing
}

src_install() {
	python_src_install
	python_clean_installation_image

	dodoc AUTHORS ChangeLog INSTALL MAPPING NEWS README THREADS TODO

	if use examples; then
		rm examples/Makefile* examples/pygtk-demo/pygtk-demo.in
		insinto /usr/share/doc/${PF}
		doins -r examples
	fi
}

pkg_postinst() {
	python_mod_optimize gtk-2.0
}

pkg_postrm() {
	python_mod_cleanup gtk-2.0
}
