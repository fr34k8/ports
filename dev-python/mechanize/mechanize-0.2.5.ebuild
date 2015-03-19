# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="4-python"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.*"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*-jython"

inherit distutils eutils

DESCRIPTION="Stateful programmatic web browsing in Python"
HOMEPAGE="http://wwwsearch.sourceforge.net/mechanize/ http://pypi.python.org/pypi/mechanize"
SRC_URI="http://wwwsearch.sourceforge.net/${PN}/src/${P}.tar.gz"

LICENSE="|| ( BSD ZPL )"
SLOT="0"
KEYWORDS="~alpha amd64 ~ia64 ~ppc ~ppc64 sparc x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~ia64-linux ~x86-linux ~x86-macos"
IUSE=""

DEPEND="$(python_abi_depend dev-python/setuptools)"
RDEPEND=""

DOCS="docs/*.txt"

src_prepare() {
	distutils_src_prepare

	# Support Jython.
	sed -e 's/os.name == "posix"/os.name in ("java", "posix")/' -i test-tools/unittest/loader.py

	# Disable failing tests.
	sed \
		-e "s/test_get_token/_&/" \
		-e "s/test_tokens/_&/" \
		-i test/test_pullparser.py
}

src_test() {
	testing() {
		# Ignore warnings (http://github.com/jjlee/mechanize/issues/issue/13).
		python_execute PYTHONPATH="build-${PYTHON_ABI}/lib" "$(PYTHON)" -Wi test.py
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install

	# Fix some paths.
	sed -e "s:../styles/:styles/:g" -i docs/html/* || die "sed failed"
	dohtml -r docs/html/ docs/styles
}
