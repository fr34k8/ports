# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="4-python"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.* *-jython"

inherit distutils

DESCRIPTION="Python interface for libpcap"
HOMEPAGE="http://pylibpcap.sourceforge.net/ http://sourceforge.net/projects/pylibpcap/ http://pypi.python.org/pypi/pylibpcap"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 ~hppa ~ia64 x86"
IUSE="examples"

DEPEND="net-libs/libpcap"
RDEPEND="${DEPEND}"

PYTHON_MODULES="pcap.py"

src_install() {
	distutils_src_install

	if use examples; then
		insinto /usr/share/doc/${PF}
		doins -r examples
	fi
}
