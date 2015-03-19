# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.1 3.2"
# 3.[4-9]: https://github.com/mitsuhiko/werkzeug/issues/502
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="3.[4-9] *-jython"
DISTUTILS_SRC_TEST="setup.py"

inherit distutils

MY_PN="Werkzeug"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Collection of various utilities for WSGI applications"
HOMEPAGE="http://werkzeug.pocoo.org/ https://github.com/mitsuhiko/werkzeug https://pypi.python.org/pypi/Werkzeug"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="redis"

RDEPEND="redis? ( $(python_abi_depend -e "*-jython" dev-python/redis-py) )"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)"

S="${WORKDIR}/${MY_P}"

DOCS="AUTHORS CHANGES"

src_prepare() {
	distutils_src_prepare

	# Disable failing tests.
	# https://github.com/mitsuhiko/werkzeug/issues/418
	sed -e "s/import pylibmc as memcache/memcache = None/" -i werkzeug/testsuite/contrib/cache.py
}

src_install() {
	distutils_src_install

	delete_tests() {
		rm -r "${ED}$(python_get_sitedir)/werkzeug/testsuite"
	}
	python_execute_function -q delete_tests
}
