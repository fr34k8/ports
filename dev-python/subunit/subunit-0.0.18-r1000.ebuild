# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*-jython"

inherit distutils

MY_PN="python-${PN}"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Python implementation of subunit test streaming protocol"
HOMEPAGE="https://launchpad.net/subunit https://pypi.python.org/pypi/python-subunit"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="|| ( Apache-2.0 BSD )"
SLOT="0"
KEYWORDS="*"
IUSE="test"

RDEPEND="$(python_abi_depend dev-python/extras)
	$(python_abi_depend ">=dev-python/testtools-0.9.34")"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)
	test? ( $(python_abi_depend dev-python/testscenarios) )"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	distutils_src_prepare

	# https://bugs.launchpad.net/subunit/+bug/1292757
	sed -e "/testscenarios/d" -i setup.py
}

src_test() {
	testing() {
		python_execute PYTHONPATH="python" "$(PYTHON)" -m testtools.run subunit.test_suite
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install

	delete_tests() {
		rm -fr "${ED}$(python_get_sitedir)/subunit/tests"
	}
	python_execute_function -q delete_tests
}
