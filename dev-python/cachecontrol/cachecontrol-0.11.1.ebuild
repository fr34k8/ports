# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"

inherit distutils

MY_PN="CacheControl"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="httplib2 caching for requests"
HOMEPAGE="https://github.com/ionrock/cachecontrol https://pypi.python.org/pypi/CacheControl"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="$(python_abi_depend dev-python/lockfile)
	$(python_abi_depend dev-python/requests)
	$(python_abi_depend dev-python/urllib3)"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)"

S="${WORKDIR}/${MY_P}"
