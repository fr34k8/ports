# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_EXPORT_PHASE_FUNCTIONS="1"
PYTHON_RESTRICTED_ABIS="2.5 3.* *-jython *-pypy-*"

inherit eutils python

DESCRIPTION="Python bindings for libnotify"
HOMEPAGE="http://www.galago-project.org/"
SRC_URI="http://www.galago-project.org/files/releases/source/${PN}/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"
IUSE="examples"

RDEPEND="$(python_abi_depend ">=dev-python/pygtk-2.24:2")
	>=x11-libs/libnotify-0.7"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_prepare() {
	epatch "${FILESDIR}/${P}-libnotify-0.7.patch"

	python_clean_py-compile_files

	# Regenerate src/pynotify.c.
	rm -f src/pynotify.c

	python_src_prepare
}

src_install() {
	python_src_install
	python_clean_installation_image
	dodoc AUTHORS ChangeLog NEWS README

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins tests/*.{png,py}
	fi
}

pkg_postinst() {
	python_mod_optimize gtk-2.0/pynotify
}

pkg_postrm() {
	python_mod_cleanup gtk-2.0/pynotify
}
