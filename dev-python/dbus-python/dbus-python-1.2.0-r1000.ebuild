# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.5 *-jython *-pypy-*"
PYTHON_EXPORT_PHASE_FUNCTIONS="1"

inherit python

DESCRIPTION="Python bindings for the D-Bus messagebus"
HOMEPAGE="http://www.freedesktop.org/wiki/Software/DBusBindings http://dbus.freedesktop.org/doc/dbus-python/"
SRC_URI="http://dbus.freedesktop.org/releases/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="doc examples test"

RDEPEND=">=dev-libs/dbus-glib-0.70:=
	>=sys-apps/dbus-1.6:="
DEPEND="${RDEPEND}
	virtual/pkgconfig
	doc? ( =dev-python/epydoc-3* )
	test? ( $(python_abi_depend dev-python/pygobject:3) )"

src_prepare() {
	# Fix tests with Python 3.1.
	sed -e 's/if sys.version_info\[:2\] >= (2, 7):/if sys.version_info[:2] == (2, 7) or sys.version_info[:2] >= (3, 2):/' -i test/test-standalone.py || die "sed failed"

	python_clean_py-compile_files
	python_src_prepare
}

src_configure() {
	configuration() {
		py_cv_mod_docutils___version__="yes" econf \
			--docdir="${EPREFIX}/usr/share/doc/${PF}" \
			--disable-html-docs \
			$(use_enable doc api-docs)
	}
	python_execute_function -s configuration
}

src_test() {
	unset DBUS_SESSION_BUS_ADDRESS
	python_src_test
}

src_install() {
	python_src_install

	if use doc; then
		install_documentation() {
			nonfatal dohtml -r api/*
		}
		python_execute_function -f -q -s install_documentation
	fi

	if use examples; then
		insinto /usr/share/doc/${PF}
		doins -r examples
	fi

	python_clean_installation_image
}

pkg_postinst() {
	python_mod_optimize dbus
}

pkg_postrm() {
	python_mod_cleanup dbus
}
