# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_DEPEND="<<[{*-cpython}xml]>>"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.*"

inherit distutils eutils multilib

DESCRIPTION="Collection of Gentoo-specific tools for Java"
HOMEPAGE="http://www.gentoo.org/proj/en/java/"
SRC_URI="mirror://gentoo/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND=""
RDEPEND=""

PYTHON_VERSIONED_SCRIPTS=("/usr/lib(32|64)?/${PN}/bin/.*")
PYTHON_MODULES="javatoolkit"

src_prepare(){
	distutils_src_prepare
	epatch "${FILESDIR}/${P}-python2.6.patch"
	epatch "${FILESDIR}/${P}-no-pyxml.patch"
}

src_install() {
	distutils_src_install --install-scripts="${EPREFIX}/usr/$(get_libdir)/${PN}/bin"
}
