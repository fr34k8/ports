# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.1 3.2"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*-jython"

inherit distutils

DESCRIPTION="Simple, fast, extensible JSON encoder/decoder for Python"
HOMEPAGE="https://github.com/simplejson/simplejson https://pypi.python.org/pypi/simplejson"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="|| ( AFL-2.1 MIT )"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="$(python_abi_depend dev-python/setuptools)"
RDEPEND=""

PYTHON_CFLAGS=("2.* + -fno-strict-aliasing")

DOCS="CHANGES.txt README.rst"

src_prepare() {
	distutils_src_prepare

	# https://github.com/simplejson/simplejson/issues/70
	sed \
		-e "/'simplejson.tests.test_scanstring',/d" \
		-e "65s/\])/] + ([] if sys.platform.startswith('java') else ['simplejson.tests.test_scanstring']))/" \
		-i simplejson/tests/__init__.py
}

src_test() {
	testing() {
		if [[ "$(python_get_implementation)" != "Jython" ]]; then
			ln -fs ../$(ls -d build-${PYTHON_ABI}/lib*)/simplejson/_speedups$(python_get_extension_module_suffix) simplejson/_speedups$(python_get_extension_module_suffix) || return 1
		fi
		python_execute PYTHONPATH="$([[ -d build-${PYTHON_ABI}/lib ]] && echo build-${PYTHON_ABI}/lib || ls -d build-${PYTHON_ABI}/lib*)" "$(PYTHON)" simplejson/tests/__init__.py
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install

	delete_tests() {
		rm -r "${ED}$(python_get_sitedir)/simplejson/tests"
	}
	python_execute_function -q delete_tests
}
