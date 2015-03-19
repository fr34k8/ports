# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_TESTS_RESTRICTED_ABIS="3.1 *-jython *-pypy-*"

inherit distutils

DESCRIPTION="cssselect parses CSS3 Selectors and translates them to XPath 1.0"
HOMEPAGE="https://pythonhosted.org/cssselect/ https://pypi.python.org/pypi/cssselect"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="doc test"

DEPEND="$(python_abi_depend dev-python/setuptools)
	doc? ( $(python_abi_depend dev-python/sphinx) )
	test? ( $(python_abi_depend -e "${PYTHON_TESTS_RESTRICTED_ABIS}" dev-python/lxml) )"
RDEPEND=""

DOCS="AUTHORS CHANGES README.rst"

src_compile() {
	distutils_src_compile

	if use doc; then
		einfo "Generation of documentation"
		python_execute "$(PYTHON -f)" setup.py build_sphinx || die "Generation of documentation failed"
	fi
}

src_test() {
	testing() {
		python_execute PYTHONPATH="build-${PYTHON_ABI}/lib" "$(PYTHON)" cssselect/tests.py -v
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install

	delete_tests() {
		rm "${ED}$(python_get_sitedir)/cssselect/tests.py"
	}
	python_execute_function -q delete_tests

	if use doc; then
		dohtml -r docs/_build/html/
	fi
}
