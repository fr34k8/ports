# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="4-python"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.5 3.* *-jython *-pypy-*"

inherit distutils

DESCRIPTION="A layout component package for zope3 and Grok."
HOMEPAGE="http://grok.zope.org/ http://pypi.python.org/pypi/grokcore.layout"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="ZPL"
SLOT="0"
KEYWORDS="amd64 ~ppc ~ppc64 sparc x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND="$(python_abi_depend net-zope/namespaces-grok)
	$(python_abi_depend ">=dev-python/martian-0.14")
	$(python_abi_depend ">=net-zope/grokcore.component-2.5")
	$(python_abi_depend ">=net-zope/grokcore.security-1.6")
	$(python_abi_depend ">=net-zope/grokcore.view-2.7")
	$(python_abi_depend ">=net-zope/zope.component-3.9.1")
	$(python_abi_depend net-zope/zope.errorview)
	$(python_abi_depend net-zope/zope.interface)
	$(python_abi_depend net-zope/zope.publisher)
	$(python_abi_depend net-zope/zope.security)"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)"

DOCS="CHANGES.txt src/grokcore/layout/README.txt"
PYTHON_MODULES="${PN/.//}"
