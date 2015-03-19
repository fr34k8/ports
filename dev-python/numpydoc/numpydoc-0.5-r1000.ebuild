# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
DISTUTILS_SRC_TEST="nosetests"

inherit distutils

DESCRIPTION="Sphinx extension to support docstrings in Numpy format"
HOMEPAGE="https://github.com/numpy/numpydoc https://pypi.python.org/pypi/numpydoc"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD BSD-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="$(python_abi_depend dev-python/sphinx)"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)"

src_prepare() {
	distutils_src_prepare

	# Fix compatibility with Python 3.1 and 3.2.
	sed -e "s/ or (3, 0) <= sys.version_info\[0:2\] < (3, 3)//" -i setup.py
	sed -e "s/callable(\([^)]\+\))/(hasattr(\1, '__call__') if __import__('sys').version_info\[:2\] == (3, 1) else &)/" -i numpydoc/docscrape_sphinx.py

	# Delete deprecated module, which requireth dev-python/matplotlib.
	rm numpydoc/plot_directive.py numpydoc/tests/test_plot_directive.py
}

src_install() {
	distutils_src_install

	delete_tests() {
		rm -r "${ED}$(python_get_sitedir)/numpydoc/tests"
	}
	python_execute_function -q delete_tests
}
