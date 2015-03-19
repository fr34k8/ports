# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
PYTHON_RESTRICTED_ABIS="2.6 3.* *-jython"

inherit distutils

DESCRIPTION="Mozilla-authored device management"
HOMEPAGE="https://pypi.python.org/pypi/mozdevice"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="$(python_abi_depend ">=dev-python/mozfile-1.0")
	$(python_abi_depend ">=dev-python/mozlog-2.1")
	$(python_abi_depend dev-python/moznetwork)
	$(python_abi_depend ">=dev-python/mozprocess-0.19")
	$(python_abi_depend dev-python/setuptools)"
RDEPEND="${DEPEND}"
