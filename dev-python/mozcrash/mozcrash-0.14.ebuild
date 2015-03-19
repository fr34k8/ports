# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.6 3.* *-jython"

inherit distutils

DESCRIPTION="Library for printing stack traces from minidumps left behind by crashed processes"
HOMEPAGE="https://pypi.python.org/pypi/mozcrash"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="$(python_abi_depend ">=dev-python/mozfile-1.0")
	$(python_abi_depend dev-python/mozlog)"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)"
