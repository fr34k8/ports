# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
GCONF_DEBUG="no"
GNOME2_LA_PUNT="yes"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="*-jython *-pypy-*"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="2.6"

inherit autotools eutils gnome2 python virtualx

DESCRIPTION="GLib's GObject library bindings for Python"
HOMEPAGE="http://www.pygtk.org/"
SRC_URI+=" python_abis_2.6? ( mirror://gnome/sources/${PN}/3.8/${PN}-3.8.3.tar.xz )"

LICENSE="LGPL-2.1+"
SLOT="3"
KEYWORDS="*"
IUSE="+cairo examples test +threads"
REQUIRED_USE="test? ( cairo )"

COMMON_DEPEND=">=dev-libs/glib-2.35.9:2
	>=dev-libs/gobject-introspection-1.35.9
	virtual/libffi:=
	cairo? ( $(python_abi_depend ">=dev-python/pycairo-1.10.0") )"
DEPEND="${COMMON_DEPEND}
	gnome-base/gnome-common
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
# gnome-base/gnome-common required by eautoreconf

# We now disable introspection support in slot 2 per upstream recommendation
# (see https://bugzilla.gnome.org/show_bug.cgi?id=642048#c9); however,
# older versions of slot 2 installed their own site-packages/gi, and
# slot 3 will collide with them.
RDEPEND="${COMMON_DEPEND}
	cairo? ( x11-libs/cairo )
	!<dev-python/pygtk-2.13
	!<dev-python/pygobject-2.28.6-r50:2[introspection]"

src_prepare() {
	preparation() {
		if [[ "$(python_get_version -l)" == "2.6" ]]; then
			cp -pr "${WORKDIR}/${PN}-3.8.3" "${S}-${PYTHON_ABI}"
		else
			cp -pr "${WORKDIR}/${P}" "${S}-${PYTHON_ABI}"
		fi

		cd "${S}-${PYTHON_ABI}"

		# Fix compatibility with Python 2.6 and 3.1.
		if [[ "$(python_get_version -l)" == "2.6" ]]; then
			sed -e "s/if sys.version_info\[:2\] == (2, 6):/if False:/" -i tests/runtests.py || die

			# Do not build tests if unneeded, bug #226345, upstream bug #698444
			epatch "${FILESDIR}/${PN}-3.7.90-make_check.patch"
		elif [[ "$(python_get_version -l)" == "3.1" ]]; then
			sed -e "s/sys.version_info\[:2\] == (2, 7)/sys.version_info[:2] in ((2, 7), (3, 1))/" -i tests/runtests.py || die
			sed -e "s/callable(\([^)]\+\))/(hasattr(\1, '__call__') if __import__('sys').version_info\[:2\] == (3, 1) else &)/" -i gi/overrides/GLib.py tests/test_gi.py || die
			sed -e "s/\([[:space:]]*\)def test_struct_method(self):/\1@unittest.skipIf(__import__('sys').version_info\[:2\] in ((2, 6), (3, 1)), 'Python 2.6 or 3.1')\n&/" -i tests/test_gi.py || die
		fi
		sed -e "s/import unittest/if __import__('sys').version_info\[:2\] in ((2, 6), (3, 1)):\n    unittest = __import__('unittest2')\nelse:\n    unittest = __import__('unittest')/" -i tests/*.py || die
		sed -e "s/\(assertAlmostEqual([^,]\+,[[:space:]]*[^,]\+,[[:space:]]*\)\([[:digit:]]\+\)/\1places=\2/" -i tests/*.py || die
		sed -e "s/\([[:space:]]*\)def test_help(self):/\1@unittest.skipIf(__import__('sys').version_info\[:2\] in ((2, 6), (3, 1)), 'Python 2.6 or 3.1')\n&/" -i tests/test_gi.py || die

		# Disable Pyflakes check.
		sed \
			-e "/^\t@echo \"  CHECK  Pyflakes\"/d" \
			-e "/^\t@if type pyflakes/d" \
			-i tests/Makefile.am

		eautoreconf
		S="$(pwd)" gnome2_src_prepare
		python_clean_py-compile_files
	}
	python_execute_function preparation
}

src_configure() {
	# Hard-enable libffi support since both gobject-introspection and
	# glib-2.29.x rdepend on it anyway
	# docs disabled by upstream default since they are very out of date
	configuration() {
		PYTHON="$(PYTHON)" gnome2_src_configure \
			--with-ffi \
			$(use_enable cairo) \
			$(use_enable threads thread)
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
		Xemake check PYTHON="$(PYTHON -a)" SKIP_PEP8="1"
		unset XDG_CACHE_HOME
	}
	python_execute_function -s testing
	unset GIO_USE_VFS
}

src_install() {
	DOCS="AUTHORS ChangeLog* NEWS README"

	python_execute_function -s gnome2_src_install
	python_clean_installation_image

	if use examples; then
		insinto /usr/share/doc/${PF}
		doins -r examples
	fi
}

pkg_postinst() {
	python_mod_optimize gi pygtkcompat
}

pkg_postrm() {
	python_mod_cleanup gi pygtkcompat
}
