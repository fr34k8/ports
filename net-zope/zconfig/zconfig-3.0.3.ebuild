# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
DISTUTILS_SRC_TEST="nosetests"

inherit distutils

MY_PN="ZConfig"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Structured Configuration Library"
HOMEPAGE="https://pypi.python.org/pypi/ZConfig"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="ZPL"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="$(python_abi_depend dev-python/setuptools)"
RDEPEND=""

S="${WORKDIR}/${MY_P}"

DOCS="CHANGES.txt README.txt"
PYTHON_MODULES="${MY_PN}"

src_install() {
	distutils_src_install

	delete_tests() {
		rm -fr "${ED}$(python_get_sitedir)/ZConfig/components/basic/tests"
		rm -fr "${ED}$(python_get_sitedir)/ZConfig/components/logger/tests"
		rm -fr "${ED}$(python_get_sitedir)/ZConfig/tests"
	}
	python_execute_function -q delete_tests
}
