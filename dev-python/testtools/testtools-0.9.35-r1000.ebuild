# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_TESTS_RESTRICTED_ABIS="*-jython"

inherit distutils

DESCRIPTION="Extensions to the Python standard library unit testing framework"
HOMEPAGE="https://github.com/testing-cabal/testtools https://launchpad.net/testtools https://pypi.python.org/pypi/testtools"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="$(python_abi_depend dev-python/extras)
	$(python_abi_depend dev-python/mimeparse)"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)"

src_test() {
	testing() {
		python_execute PYTHONPATH="build-${PYTHON_ABI}/lib" "$(PYTHON)" -m testtools.run testtools.tests.test_suite
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install

	delete_version-specific_modules() {
		if [[ "$(python_get_version -l --major)" == "2" ]]; then
			rm "${ED}$(python_get_sitedir)/testtools/_compat3x.py"
		fi
	}
	python_execute_function -q delete_version-specific_modules
}
