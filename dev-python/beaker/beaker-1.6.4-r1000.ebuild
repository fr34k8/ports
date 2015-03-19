# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
# 3.*: https://github.com/bbangert/beaker/issues/51
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="3.* *-jython"
DISTUTILS_SRC_TEST="nosetests"

inherit distutils

MY_PN="Beaker"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="A Session and Caching library with WSGI Middleware"
HOMEPAGE="https://beaker.readthedocs.org/ https://github.com/bbangert/beaker https://pypi.python.org/pypi/Beaker"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="test"

# Disabled tests from tests/test_memcached.py require dev-python/mock.
DEPEND="$(python_abi_depend dev-python/setuptools)
	test? ( $(python_abi_depend -e "3.1" dev-python/webtest) )"
RDEPEND=""

S="${WORKDIR}/${MY_P}"

DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES="1"

src_prepare() {
	# Skip Memcached tests.
	sed -e "/from nose import SkipTest/a raise SkipTest" -i tests/test_memcached.py

	distutils_src_prepare

	prepare_tests() {
		if [[ "$(python_get_version -l --major)" == "3" ]]; then
			2to3-${PYTHON_ABI} -nw --no-diffs tests
		fi
	}
	python_execute_function -s prepare_tests
}
