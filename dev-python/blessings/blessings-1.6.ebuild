# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_DEPEND="<<[ncurses]>>"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.1 *-jython"
DISTUTILS_SRC_TEST="nosetests"

inherit distutils

DESCRIPTION="A thin, practical wrapper around terminal coloring, styling, and positioning"
HOMEPAGE="https://github.com/erikrose/blessings https://pypi.python.org/pypi/blessings"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="$(python_abi_depend dev-python/setuptools)"
RDEPEND=""

src_test() {
	python_execute_nosetests -e -P 'build-${PYTHON_ABI}/lib' -- -P -w 'build-${PYTHON_ABI}/lib'
}

src_install() {
	distutils_src_install

	delete_tests() {
		rm "${ED}$(python_get_sitedir)/blessings/tests.py"
	}
	python_execute_function -q delete_tests
}
