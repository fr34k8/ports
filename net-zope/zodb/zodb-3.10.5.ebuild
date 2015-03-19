# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="4-python"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.5 3.* *-jython *-pypy-*"
DISTUTILS_SRC_TEST="setup.py"

inherit distutils

MY_PN="ZODB3"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Zope Object Database: object database and persistence"
HOMEPAGE="http://pypi.python.org/pypi/ZODB3 https://launchpad.net/zodb"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="ZPL"
SLOT="0"
KEYWORDS="amd64 ~ppc ~ppc64 sparc x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND="$(python_abi_depend dev-python/manuel)
	$(python_abi_depend ">=net-zope/transaction-1.1.0")
	$(python_abi_depend net-zope/zc.lockfile)
	$(python_abi_depend net-zope/zconfig)
	$(python_abi_depend net-zope/zdaemon)
	$(python_abi_depend net-zope/zope.event)
	$(python_abi_depend net-zope/zope.interface)
	$(python_abi_depend net-zope/zope.testing)
	!media-libs/FusionSound"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)"

S="${WORKDIR}/${MY_P}"

PYTHON_CFLAGS=("2.* + -fno-strict-aliasing")

DOCS="doc/* HISTORY.txt README.txt"
PYTHON_MODULES="BTrees persistent ZEO ZODB"

src_prepare() {
	distutils_src_prepare
	python_convert_shebangs -r 2 src
}

src_install() {
	distutils_src_install
	python_clean_installation_image
}
