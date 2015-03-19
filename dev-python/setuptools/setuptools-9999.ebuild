# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*-jython"
DISTUTILS_SRC_TEST="py.test"

inherit distutils mercurial

DESCRIPTION="Setuptools is a collection of extensions to Distutils"
HOMEPAGE="https://pythonhosted.org/setuptools/ https://bitbucket.org/pypa/setuptools https://pypi.python.org/pypi/setuptools"
SRC_URI=""
EHG_REPO_URI="https://bitbucket.org/pypa/setuptools"

LICENSE="PSF-2"
SLOT="0"
KEYWORDS=""
IUSE="test"

DEPEND="test? ( $(python_abi_depend virtual/python-mock) )"
RDEPEND=""

DOCS="README.txt docs/easy_install.txt docs/pkg_resources.txt docs/setuptools.txt"
PYTHON_MODULES="_markerlib easy_install.py pkg_resources setuptools"

src_prepare() {
	distutils_src_prepare

	# Disable tests requiring network connection.
	rm setuptools/tests/test_packageindex.py
}

src_test() {
	python_execute_py.test -P 'build-${PYTHON_ABI}/lib' setuptools
}

src_install() {
	SETUPTOOLS_DISABLE_VERSIONED_EASY_INSTALL_SCRIPT="1" distutils_src_install

	delete_tests() {
		rm -r "${ED}$(python_get_sitedir)/"{pkg_resources/tests,setuptools/tests}
	}
	python_execute_function -q delete_tests
}
