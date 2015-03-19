# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
DISTUTILS_SRC_TEST="nosetests"

inherit distutils

DESCRIPTION="Fast, simple object-to-object and broadcast signaling"
HOMEPAGE="https://pythonhosted.org/blinker/ https://github.com/jek/blinker https://pypi.python.org/pypi/blinker"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="doc"

DEPEND=""
RDEPEND=""

src_install() {
	distutils_src_install

	if use doc; then
		dohtml -r docs/html/
	fi
}
