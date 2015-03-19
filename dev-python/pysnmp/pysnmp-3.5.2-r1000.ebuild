# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="4-python"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.*"

inherit distutils

MY_PN="pysnmp-se"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="SNMP framework in Python"
HOMEPAGE="http://twistedsnmp.sourceforge.net/"
SRC_URI="mirror://sourceforge/twistedsnmp/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 ~ppc sparc x86"
IUSE=""

DEPEND=""
RDEPEND=""

S="${WORKDIR}/${MY_P}"

DOCS="CHANGES COMPATIBILITY README"

src_install(){
	distutils_src_install

	dohtml -r docs/
	insinto /usr/share/doc/${PF}
	doins -r examples
}
