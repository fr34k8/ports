# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.5 3.* *-jython *-pypy-*"

inherit distutils

DESCRIPTION="Component infrastructure, based on zope.interface"
HOMEPAGE="http://pypi.python.org/pypi/zeam.component"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="$(python_abi_depend net-zope/namespaces-zeam[zeam])
	$(python_abi_depend dev-python/martian)
	$(python_abi_depend net-zope/grokcore.component)
	$(python_abi_depend net-zope/zope.component)
	$(python_abi_depend net-zope/zope.interface)
	$(python_abi_depend net-zope/zope.testing)"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)"

DOCS="README.txt docs/HISTORY.txt"
PYTHON_MODULES="${PN/.//}"
