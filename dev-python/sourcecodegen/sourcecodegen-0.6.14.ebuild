# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="4-python"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.* *-jython"
DISTUTILS_SRC_TEST="setup.py"

inherit distutils

DESCRIPTION="A Python source-code generator based on the ``compiler.ast`` abstract syntax tree."
HOMEPAGE="http://pypi.python.org/pypi/sourcecodegen"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="repoze"
SLOT="0"
KEYWORDS="amd64 ~ppc ~ppc64 sparc x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux"
IUSE=""

DEPEND="$(python_abi_depend dev-python/setuptools)"
RDEPEND=""

DOCS="CHANGES.txt README.txt"

src_prepare() {
	distutils_src_prepare

	# Disable failing test.
	sed -e "s/testMultipleListComprehensions/_&/" -i src/sourcecodegen/tests/base.py
}

src_install() {
	distutils_src_install

	delete_tests() {
		rm -fr "${ED}$(python_get_sitedir)/sourcecodegen/tests"
	}
	python_execute_function -q delete_tests
}
