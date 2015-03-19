# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.5 3.* *-jython *-pypy-*"

inherit distutils

DESCRIPTION="Grok-like configuration for zope viewlets"
HOMEPAGE="http://grok.zope.org/ http://pypi.python.org/pypi/grokcore.viewlet"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.zip"

LICENSE="ZPL"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="$(python_abi_depend net-zope/namespaces-grok)
	$(python_abi_depend ">=dev-python/martian-0.14")
	$(python_abi_depend ">=net-zope/grokcore.component-2.5")
	$(python_abi_depend ">=net-zope/grokcore.security-1.6")
	$(python_abi_depend ">=net-zope/grokcore.view-2.7")
	$(python_abi_depend net-zope/zope.browserpage)
	$(python_abi_depend net-zope/zope.component)
	$(python_abi_depend net-zope/zope.contentprovider)
	$(python_abi_depend net-zope/zope.interface)
	$(python_abi_depend net-zope/zope.publisher)
	$(python_abi_depend net-zope/zope.security)
	$(python_abi_depend net-zope/zope.viewlet)"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)"

DOCS="CHANGES.txt README.txt"
PYTHON_MODULES="${PN/.//}"
