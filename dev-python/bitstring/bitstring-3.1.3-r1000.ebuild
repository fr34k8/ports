# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="*-jython"
DISTUTILS_SRC_TEST="nosetests"

inherit distutils

DESCRIPTION="Simple construction, analysis and modification of binary data."
HOMEPAGE="http://code.google.com/p/python-bitstring/ https://pypi.python.org/pypi/bitstring"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.zip"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND=""
RDEPEND=""

DOCS="README.txt release_notes.txt"
PYTHON_MODULES="bitstring.py"

src_test() {
	distutils_src_test -w test
}
