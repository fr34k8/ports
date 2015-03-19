# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
PYTHON_RESTRICTED_ABIS="*-jython"

inherit distutils

DESCRIPTION="Alternative regular expression module, to replace re."
HOMEPAGE="https://code.google.com/p/mrab-regex-hg/ https://pypi.python.org/pypi/regex"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="PSF-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND=""
RDEPEND=""

PYTHON_CFLAGS=("2.* + -fno-strict-aliasing")

DOCS="docs/Features.rst docs/UnicodeProperties.txt"
PYTHON_MODULES="_regex_core.py regex.py"

src_test() {
	testing() {
		python_execute PYTHONPATH="$(ls -d build-${PYTHON_ABI}/lib*)" "$(PYTHON)" Python$(python_get_version -l --major)/test_regex.py
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install
	dohtml docs/Features.html

	delete_tests() {
		rm "${ED}$(python_get_sitedir)/test_regex.py"
	}
	python_execute_function -q delete_tests
}
