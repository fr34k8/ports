# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.5"
DISTUTILS_SRC_TEST="setup.py"

inherit distutils

DESCRIPTION="Useful extra bits for Python"
HOMEPAGE="https://github.com/testing-cabal/extras http://pypi.python.org/pypi/extras"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="test"

DEPEND="$(python_abi_depend dev-python/setuptools)
	test? ( $(python_abi_depend dev-python/testtools) )"
RDEPEND=""

src_install() {
	distutils_src_install

	delete_tests() {
		rm -fr "${ED}$(python_get_sitedir)/extras/tests"
	}
	python_execute_function -q delete_tests
}
