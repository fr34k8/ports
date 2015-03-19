# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
PYTHON_RESTRICTED_ABIS="3.1 *-jython"
DISTUTILS_SRC_TEST="nosetests"

inherit distutils

MY_PN="textile"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="A Python implementation of Textile, Dean Allen's Human Text Generator for creating (X)HTML."
HOMEPAGE="https://github.com/textile/python-textile https://pypi.python.org/pypi/textile"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="$(python_abi_depend -i "2.6" dev-python/ordereddict)
	$(python_abi_depend dev-python/regex)"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)"

S="${WORKDIR}/${MY_P}"

PYTHON_MODULES="${MY_PN}"

distutils_src_test_post_hook() {
	# https://github.com/nose-devs/nose/issues/815
	rm -f .coverage .noseids
}

src_install() {
	distutils_src_install

	delete_tests() {
		rm -r "${ED}$(python_get_sitedir)/textile/tests"
	}
	python_execute_function -q delete_tests
}
