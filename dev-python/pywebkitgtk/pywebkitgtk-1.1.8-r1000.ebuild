# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.5 3.* *-jython *-pypy-*"
PYTHON_EXPORT_PHASE_FUNCTIONS="1"

inherit python

DESCRIPTION="Python bindings for the WebKit GTK+ port"
HOMEPAGE="http://code.google.com/p/pywebkitgtk/"
SRC_URI="http://pywebkitgtk.googlecode.com/files/${P}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="$(python_abi_depend dev-python/pygobject:2)
	$(python_abi_depend dev-python/pygtk:2)
	dev-libs/libxslt
	>=net-libs/webkit-gtk-1.1.15:2"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_configure() {
	python_src_configure --disable-static
}

src_install() {
	python_src_install
	python_clean_installation_image
	dodoc AUTHORS MAINTAINERS NEWS README
}

pkg_postinst() {
	python_mod_optimize webkit
}

pkg_postrm() {
	python_mod_cleanup webkit
}
