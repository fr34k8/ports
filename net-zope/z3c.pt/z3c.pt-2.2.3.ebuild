# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="4-python"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.5 3.* *-jython *-pypy-*"
DISTUTILS_SRC_TEST="nosetests"

inherit distutils

DESCRIPTION="Fast ZPT engine."
HOMEPAGE="http://pypi.python.org/pypi/z3c.pt"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="ZPL"
SLOT="0"
KEYWORDS="amd64 ~ppc ~ppc64 sparc x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND="$(python_abi_depend net-zope/namespaces-z3c[z3c])
	$(python_abi_depend ">=dev-python/chameleon-2.4")
	$(python_abi_depend net-zope/zope.component)
	$(python_abi_depend net-zope/zope.contentprovider)
	$(python_abi_depend net-zope/zope.i18n)
	$(python_abi_depend net-zope/zope.security)
	$(python_abi_depend net-zope/zope.traversing)"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)"

DOCS="CHANGES.txt CONTRIBUTORS.txt README.txt"
PYTHON_MODULES="${PN/.//}"
