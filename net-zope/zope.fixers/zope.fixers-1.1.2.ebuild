# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.*"
DISTUTILS_SRC_TEST="setup.py"

inherit distutils

DESCRIPTION="2to3 fixers for Zope"
HOMEPAGE="http://pypi.python.org/pypi/zope.fixers"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.zip"

LICENSE="ZPL"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="$(python_abi_depend net-zope/namespaces-zope[zope])
	$(python_abi_depend dev-python/setuptools)"
RDEPEND="${DEPEND}"

DOCS="CHANGES.txt README.txt"
PYTHON_MODULES="${PN/.//}"
