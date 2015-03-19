# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.*"

inherit distutils

DESCRIPTION="Library to get system information for use in Mozilla testing"
HOMEPAGE="https://pypi.python.org/pypi/mozinfo"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="$(python_abi_depend ">=dev-python/mozfile-0.12")
	$(python_abi_depend dev-python/setuptools)"
RDEPEND="${DEPEND}"
