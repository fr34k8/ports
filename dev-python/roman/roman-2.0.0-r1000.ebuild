# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
DISTUTILS_SRC_TEST="setup.py"

inherit distutils

DESCRIPTION="Integer to Roman numerals converter"
HOMEPAGE="http://pypi.python.org/pypi/roman"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.zip"

LICENSE="PSF-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="!<dev-python/docutils-0.9_pre7268"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)"

DOCS="CHANGES.txt"
PYTHON_MODULES="roman.py"
