# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_TESTS_RESTRICTED_ABIS="2.*"
DISTUTILS_SRC_TEST="nosetests"

inherit distutils

MY_PN="${PN/-/.}"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="distutils/packaging-related utilities used by some of STScI's packages"
HOMEPAGE="http://www.stsci.edu/institute/software_hardware/pyraf/stsci_python https://pypi.python.org/pypi/stsci.distutils"
SRC_URI="mirror://pypi/${PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="$(python_abi_depend dev-python/namespaces-stsci)
	$(python_abi_depend ">=dev-python/d2to1-0.2.9")
	$(python_abi_depend dev-python/setuptools)"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

PYTHON_MODULES="${PN/-//}"

src_test() {
	python_execute_nosetests -e -P 'build-${PYTHON_ABI}/lib' -- -P -w 'build-${PYTHON_ABI}/lib'
}

src_install() {
	distutils_src_install

	delete_tests() {
		rm -r "${ED}$(python_get_sitedir)/stsci/distutils/tests"
	}
	python_execute_function -q delete_tests
}
