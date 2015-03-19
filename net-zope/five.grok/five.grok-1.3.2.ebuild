# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="4-python"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.5 3.* *-jython *-pypy-*"

inherit distutils

DESCRIPTION="Grok-like layer for Zope 2"
HOMEPAGE="http://pypi.python.org/pypi/five.grok"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="ZPL"
SLOT="0"
KEYWORDS="amd64 ~ppc ~ppc64 sparc x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND="$(python_abi_depend net-zope/namespaces-zope[five])
	$(python_abi_depend dev-python/martian)
	$(python_abi_depend net-zope/accesscontrol)
	$(python_abi_depend net-zope/acquisition)
	$(python_abi_depend net-zope/five.formlib)
	$(python_abi_depend net-zope/five.localsitemanager)
	$(python_abi_depend net-zope/grokcore.annotation)
	$(python_abi_depend ">=net-zope/grokcore.component-2.5")
	$(python_abi_depend net-zope/grokcore.formlib)
	$(python_abi_depend net-zope/grokcore.layout)
	$(python_abi_depend ">=net-zope/grokcore.security-1.6.1")
	$(python_abi_depend net-zope/grokcore.site)
	$(python_abi_depend net-zope/grokcore.view)
	$(python_abi_depend net-zope/grokcore.viewlet)
	$(python_abi_depend ">=net-zope/zope-2.13")
	$(python_abi_depend net-zope/zope.annotation)
	$(python_abi_depend net-zope/zope.component)
	$(python_abi_depend net-zope/zope.container)
	$(python_abi_depend net-zope/zope.formlib)
	$(python_abi_depend net-zope/zope.interface)
	$(python_abi_depend net-zope/zope.location)
	$(python_abi_depend net-zope/zope.pagetemplate)
	$(python_abi_depend net-zope/zope.publisher)
	$(python_abi_depend net-zope/zope.traversing)"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)"

DOCS="docs/CREDITS.txt docs/HISTORY.txt README.txt"
PYTHON_MODULES="${PN/.//}"

src_prepare() {
	distutils_src_prepare
	sed -e "s/from zope.location.interfaces import IPossibleSite/from zope.component.interfaces import IPossibleSite/" -i src/five/grok/components.py
}
