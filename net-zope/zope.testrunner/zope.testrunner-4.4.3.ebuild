# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"

inherit distutils

DESCRIPTION="Zope testrunner script."
HOMEPAGE="https://pypi.python.org/pypi/zope.testrunner"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.zip"

LICENSE="ZPL"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="$(python_abi_depend net-zope/namespaces-zope[zope])
	$(python_abi_depend dev-python/setuptools)
	$(python_abi_depend dev-python/six)
	$(python_abi_depend net-zope/zope.exceptions)
	$(python_abi_depend net-zope/zope.interface)
	!<net-zope/zope.testing-3.10.0"
RDEPEND="${DEPEND}"

DOCS="CHANGES.rst README.rst"
PYTHON_MODULES="${PN/.//}"

src_install() {
	distutils_src_install

	delete_tests() {
		rm -fr "${ED}$(python_get_sitedir)/zope/testrunner/tests"
	}
	python_execute_function -q delete_tests
}
