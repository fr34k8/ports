# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*-jython"
DISTUTILS_SRC_TEST="nosetests"

inherit distutils

DESCRIPTION="A CSS Cascading Style Sheets library for Python"
HOMEPAGE="https://bitbucket.org/cthedot/cssutils https://pypi.python.org/pypi/cssutils"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.zip"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="$(python_abi_depend dev-python/setuptools)"
DEPEND="${RDEPEND}
	test? ( $(python_abi_depend dev-python/mock) )"

PYTHON_MODULES="cssutils encutils"

src_prepare() {
	distutils_src_prepare

	# https://bitbucket.org/cthedot/cssutils/issue/42
	sed -e "158s:('text/html', 'ascii'):& if (sys.version_info >= (2, 7, 3) and sys.version_info < (3, 0) or sys.version_info >= (3, 3)) else (None, None):" -i src/cssutils/tests/test_encutils/__init__.py
}

distutils_src_compile_post_hook() {
	# Tests use path relative to sheets directory.
	ln -s ../sheets build-${PYTHON_ABI}/sheets
}

src_test() {
	python_execute_nosetests -e -P 'build-${PYTHON_ABI}/lib' -- -P 'build-${PYTHON_ABI}/lib'
}

src_install() {
	distutils_src_install

	delete_tests_and_version-specific_modules() {
		rm -r "${ED}$(python_get_sitedir)/cssutils/tests"

		if [[ "$(python_get_version -l --major)" == "2" ]]; then
			rm "${ED}$(python_get_sitedir)/cssutils/_codec3.py"
		else
			rm "${ED}$(python_get_sitedir)/cssutils/_codec2.py"
		fi
	}
	python_execute_function -q delete_tests_and_version-specific_modules
}
