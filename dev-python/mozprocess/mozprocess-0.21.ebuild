# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.6 3.* *-jython"

inherit distutils

DESCRIPTION="Mozilla-authored process handling"
HOMEPAGE="https://pypi.python.org/pypi/mozprocess"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="$(python_abi_depend dev-python/mozinfo)"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)"
