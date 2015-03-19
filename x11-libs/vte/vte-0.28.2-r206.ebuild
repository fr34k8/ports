# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
GCONF_DEBUG="yes"
GNOME2_LA_PUNT="yes"
PYTHON_DEPEND="python? ( <<>> )"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.5 3.* *-jython *-pypy-*"

inherit autotools eutils gnome2 python

DESCRIPTION="GNOME terminal widget"
HOMEPAGE="https://live.gnome.org/VTE"

LICENSE="LGPL-2+"
SLOT="0"
KEYWORDS="*"
IUSE="debug glade +introspection python"

PDEPEND="x11-libs/gnome-pty-helper"
RDEPEND=">=dev-libs/glib-2.26:2
	>=x11-libs/gtk+-2.20:2[introspection?]
	>=x11-libs/pango-1.22.0

	sys-libs/ncurses
	x11-libs/libX11
	x11-libs/libXft

	glade? ( dev-util/glade:3 )
	introspection? ( >=dev-libs/gobject-introspection-0.9.0 )
	python? ( $(python_abi_depend dev-python/pygtk:2) )"
DEPEND="${RDEPEND}
	dev-util/gtk-doc-am
	>=dev-util/intltool-0.35
	sys-devel/gettext
	virtual/pkgconfig"

pkg_setup() {
	# Do not disable gnome-pty-helper, bug #401389
	G2CONF="${G2CONF}
		--disable-deprecation
		--disable-static
		$(use_enable debug)
		$(use_enable glade glade-catalogue)
		$(use_enable introspection)
		$(use_enable python)
		--with-gtk=2.0"

	DOCS="AUTHORS ChangeLog HACKING NEWS README"

	if use python; then
		python_pkg_setup
	fi
}

src_prepare() {
	# https://bugzilla.gnome.org/show_bug.cgi?id=663779
	epatch "${FILESDIR}/${PN}-0.30.1-alt-meta.patch"

	# Fix CVE-2012-2738, upstream bug #676090
	epatch "${FILESDIR}"/${PN}-0.28.2-limit-arguments.patch

	# Python bindings are built/installed manually.
	# Avoid eautoreconf. 'am__append_1 = python' in Makefile.
	sed -e "/^SUBDIRS =/s/ \$(am__append_1)//" -i Makefile.in

	gnome2_src_prepare
}

src_compile() {
	gnome2_src_compile

	if use python; then
		python_copy_sources python

		building() {
			emake \
				PYTHON_INCLUDES="-I$(python_get_includedir)" \
				pyexecdir="$(python_get_sitedir)"
		}
		python_execute_function -s --source-dir python building
	fi
}

src_install() {
	gnome2_src_install
	rm -f "${ED}usr/libexec/gnome-pty-helper" || die

	if use python; then
		installation() {
			emake \
				DESTDIR="${D}" \
				PYTHON_INCLUDES="-I$(python_get_includedir)" \
				pyexecdir="$(python_get_sitedir)" \
				install
		}
		python_execute_function -s --source-dir python installation

		python_clean_installation_image
	fi
}
