# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.1 *-jython"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="2.6"

inherit distutils

DESCRIPTION="Python web framework and asynchronous networking library"
HOMEPAGE="http://www.tornadoweb.org/ https://github.com/facebook/tornado https://pypi.python.org/pypi/tornado"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="curl test"

RDEPEND="$(python_abi_depend -i "2.* 3.1" dev-python/backports.ssl_match_hostname)
	curl? ( $(python_abi_depend -e "*-pypy-*" dev-python/pycurl) )"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)
	test? ( $(python_abi_depend -i "2.6" dev-python/unittest2) )"

src_prepare() {
	distutils_src_prepare

	# Avoid test failures with unittest2 and Python >=2.7.
	sed \
		-e "51s/try:/if __import__(\"sys\").version_info < (2, 7):/" \
		-e "53s/except ImportError:/else:/" \
		-i tornado/testing.py
}

src_test() {
	testing() {
		python_execute PYTHONPATH="build-${PYTHON_ABI}/lib" "$(PYTHON)" -m tornado.test.runtests
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install

	delete_tests() {
		rm -r "${ED}$(python_get_sitedir)/tornado/test"
	}
	python_execute_function -q delete_tests
}
