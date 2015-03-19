# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
DISTUTILS_SRC_TEST="setup.py"

inherit distutils

DESCRIPTION="A generator library for concise, unambiguous and URL-safe UUIDs."
HOMEPAGE="https://github.com/stochastic-technologies/shortuuid https://pypi.python.org/pypi/shortuuid"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="test"

DEPEND="$(python_abi_depend dev-python/setuptools)
	test? ( $(python_abi_depend dev-python/pep8) )"
RDEPEND=""

DOCS="README.rst"

src_install() {
	distutils_src_install

	delete_tests() {
		rm "${ED}$(python_get_sitedir)/shortuuid/tests.py"
	}
	python_execute_function -q delete_tests
}
