# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="4-python"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.* *-jython *-pypy-*"
DISTUTILS_SRC_TEST="py.test"

inherit distutils

DESCRIPTION="job queue server"
HOMEPAGE="https://github.com/pediapress/qserve http://pypi.python.org/pypi/qserve"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.zip"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="$(python_abi_depend dev-python/gevent)
	$(python_abi_depend virtual/python-json[external])"
DEPEND="${RDEPEND}
	app-arch/unzip
	$(python_abi_depend dev-python/setuptools)"

PYTHON_MODULES="qs"
