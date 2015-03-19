# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="4-python"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.5 3.* *-jython *-pypy-*"
DISTUTILS_SRC_TEST="nosetests"

inherit distutils

MY_PN="zExceptions"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="zExceptions contains common exceptions used in Zope2."
HOMEPAGE="http://pypi.python.org/pypi/zExceptions"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.zip"

LICENSE="ZPL"
SLOT="0"
KEYWORDS="amd64 ~ppc ~ppc64 sparc x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND="$(python_abi_depend net-zope/zope.interface)
	$(python_abi_depend net-zope/zope.publisher)
	$(python_abi_depend net-zope/zope.security)"
DEPEND="${RDEPEND}
	app-arch/unzip
	$(python_abi_depend dev-python/setuptools)"

S="${WORKDIR}/${MY_P}"

DOCS="CHANGES.txt README.txt"
PYTHON_MODULES="${MY_PN}"

src_install() {
	distutils_src_install

	delete_tests() {
		rm -fr "${ED}$(python_get_sitedir)/zExceptions/tests"
	}
	python_execute_function -q delete_tests
}
