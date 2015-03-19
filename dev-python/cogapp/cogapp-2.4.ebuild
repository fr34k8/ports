# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
# *-jython: http://bugs.jython.org/issue2259
PYTHON_RESTRICTED_ABIS="*-jython"
DISTUTILS_SRC_TEST="nosetests"

inherit distutils

DESCRIPTION="Cog: A code generator for executing Python snippets in source files."
HOMEPAGE="http://nedbatchelder.com/code/cog/ https://pypi.python.org/pypi/cogapp"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="test"

DEPEND="$(python_abi_depend dev-python/setuptools)
	test? ( $(python_abi_depend -i "2.6" dev-python/unittest2) )"
RDEPEND=""

src_prepare() {
	distutils_src_prepare

	# Use unittest2 only with Python <2.7.
	sed \
		-e "13s/^try:$/if sys.version_info[:2] < (2, 7):/" \
		-e "15s/^except ImportError:$/else:/" \
		-i cogapp/test_cogapp.py
}

src_install() {
	distutils_src_install

	delete_tests() {
		rm "${ED}$(python_get_sitedir)/cogapp/test_"*
	}
	python_execute_function -q delete_tests
}
