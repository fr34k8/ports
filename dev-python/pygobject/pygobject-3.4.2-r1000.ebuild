# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
GCONF_DEBUG="no"
GNOME2_LA_PUNT="yes"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="*-jython *-pypy-*"

inherit autotools eutils gnome2 python virtualx

DESCRIPTION="GLib's GObject library bindings for Python"
HOMEPAGE="http://www.pygtk.org/"

LICENSE="LGPL-2.1+"
SLOT="3"
KEYWORDS="*"
IUSE="+cairo examples test +threads"
REQUIRED_USE="test? ( cairo )"

COMMON_DEPEND=">=dev-libs/glib-2.31.0:2
	>=dev-libs/gobject-introspection-1.34.1.1
	virtual/libffi:=
	cairo? ( $(python_abi_depend ">=dev-python/pycairo-1.10.0") )"
DEPEND="${COMMON_DEPEND}
	virtual/pkgconfig
	cairo? ( x11-libs/cairo[glib] )
	test? (
		dev-libs/atk[introspection]
		$(python_abi_depend -i "2.6 3.1" dev-python/unittest2)
		media-fonts/font-cursor-misc
		media-fonts/font-misc-misc
		x11-libs/gdk-pixbuf:2[introspection]
		x11-libs/gtk+:3[introspection]
		x11-libs/pango[introspection] )"

# We now disable introspection support in slot 2 per upstream recommendation
# (see https://bugzilla.gnome.org/show_bug.cgi?id=642048#c9); however,
# older versions of slot 2 installed their own site-packages/gi, and
# slot 3 will collide with them.
RDEPEND="${COMMON_DEPEND}
	cairo? ( x11-libs/cairo )
	!<dev-python/pygtk-2.13
	!<dev-python/pygobject-2.28.6-r50:2[introspection]"

src_prepare() {
	DOCS="AUTHORS ChangeLog* NEWS README"
	# Hard-enable libffi support since both gobject-introspection and
	# glib-2.29.x rdepend on it anyway
	# docs disabled by upstream default since they are very out of date
	G2CONF="${G2CONF}
		--with-ffi
		$(use_enable cairo)
		$(use_enable threads thread)"

	# Do not build tests if unneeded, bug #226345
	epatch "${FILESDIR}/${PN}-3.4.1.1-make_check.patch"

	# Fix tests with Python 2.6 and 3.1.
	sed -e "s/if sys.version_info\[:2\] == (2, 6):/if False:/" -i tests/runtests.py || die
	sed -e "s/import unittest/if __import__('sys').version_info\[:2\] in ((2, 6), (3, 1)):\n    unittest = __import__('unittest2')\nelse:\n    unittest = __import__('unittest')/" -i tests/*.py || die
	sed -e "s/\(assertAlmostEqual([^,]\+,[[:space:]]*[^,]\+,[[:space:]]*\)\([[:digit:]]\+\)/\1places=\2/" -i tests/*.py || die
	sed -e "s/callable(\([^)]\+\))/hasattr(\1, '__call__') if __import__('sys').version_info\[:2\] == (3, 1) else &/" -i tests/test_gi.py || die
	sed -e "s/\([[:space:]]*\)def test_help(self):/\1@unittest.skipIf(__import__('sys').version_info\[:2\] in ((2, 6), (3, 1)), 'Python 2.6 or 3.1')\n&/" -i tests/test_gi.py || die

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
	configuration() {
		PYTHON="$(PYTHON)" gnome2_src_configure
	}
	python_execute_function -s configuration
}

src_compile() {
	python_src_compile
}

src_test() {
	unset DBUS_SESSION_BUS_ADDRESS
	export GIO_USE_VFS="local" # prevents odd issues with deleting ${T}/.gvfs
	export GIO_USE_VOLUME_MONITOR="unix" # prevent udisks-related failures in chroots, bug #449484

	testing() {
		export XDG_CACHE_HOME="${T}/${PYTHON_ABI}"
		Xemake check PYTHON="$(PYTHON -a)"
		unset XDG_CACHE_HOME
	}
	python_execute_function -s testing
	unset GIO_USE_VFS
}

src_install() {
	python_execute_function -s gnome2_src_install
	python_clean_installation_image

	if use examples; then
		insinto /usr/share/doc/${PF}
		doins -r examples
	fi
}

pkg_postinst() {
	python_mod_optimize gi
}

pkg_postrm() {
	python_mod_cleanup gi
}
