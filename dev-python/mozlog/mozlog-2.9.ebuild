# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
PYTHON_RESTRICTED_ABIS="2.6 3.* *-jython"

inherit distutils

DESCRIPTION="Robust log handling specialized for logging in the Mozilla universe"
HOMEPAGE="https://pypi.python.org/pypi/mozlog"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="$(python_abi_depend dev-python/blessings)
	$(python_abi_depend dev-python/setuptools)"
RDEPEND="${DEPEND}"
