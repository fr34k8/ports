# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
# *-jython: http://bugs.jython.org/issue1682864
PYTHON_TESTS_RESTRICTED_ABIS="*-jython"
DISTUTILS_SRC_TEST="setup.py"

inherit distutils

DESCRIPTION="Minimal Zope/SQLAlchemy transaction integration"
HOMEPAGE="https://pypi.python.org/pypi/zope.sqlalchemy"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.zip"

LICENSE="ZPL"
SLOT="0"
KEYWORDS="*"
IUSE="test"

RDEPEND="$(python_abi_depend net-zope/namespaces-zope[zope])
	$(python_abi_depend ">=dev-python/sqlalchemy-0.5.1")
	$(python_abi_depend net-zope/transaction)
	$(python_abi_depend net-zope/zope.interface)"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)
	test? (
		$(python_abi_depend -e "${PYTHON_TESTS_RESTRICTED_ABIS}" dev-python/sqlalchemy[sqlite])
		$(python_abi_depend -e "${PYTHON_TESTS_RESTRICTED_ABIS}" net-zope/zope.testing)
	)"

DOCS="CHANGES.txt CREDITS.txt src/zope/sqlalchemy/README.txt"
PYTHON_MODULES="${PN/.//}"
