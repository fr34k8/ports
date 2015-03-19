# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="3.1"

inherit distutils

DESCRIPTION="Testscenarios, a pyunit extension for dependency injection"
HOMEPAGE="https://launchpad.net/testscenarios https://pypi.python.org/pypi/testscenarios"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="$(python_abi_depend dev-python/testtools)"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)"

src_test() {
	testing() {
		python_execute PYTHONPATH="lib" "$(PYTHON)" -m testtools.run testscenarios.test_suite
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install

	delete_tests() {
		rm -r "${ED}$(python_get_sitedir)/testscenarios/tests"
	}
	python_execute_function -q delete_tests
}
