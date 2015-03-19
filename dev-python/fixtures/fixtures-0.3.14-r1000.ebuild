# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.5"
DISTUTILS_SRC_TEST="nosetests"

inherit distutils

DESCRIPTION="Fixtures, reusable state for writing clean tests and more."
HOMEPAGE="https://launchpad.net/python-fixtures https://pypi.python.org/pypi/fixtures"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="|| ( Apache-2.0 BSD )"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="$(python_abi_depend dev-python/testtools)"
RDEPEND="${DEPEND}"

DOCS="GOALS NEWS README"

src_test() {
	distutils_src_test lib/fixtures/tests/test_*.py
}

src_install() {
	distutils_src_install

	delete_tests() {
		rm -fr "${ED}$(python_get_sitedir)/fixtures/tests"
	}
	python_execute_function -q delete_tests
}
