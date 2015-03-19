# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="4-python"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.5 3.* *-jython *-pypy-*"

inherit distutils

DESCRIPTION="zope.formlib integration for Zope 2"
HOMEPAGE="http://pypi.python.org/pypi/five.formlib"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.zip"

LICENSE="ZPL"
SLOT="0"
KEYWORDS="amd64 ~ppc ~ppc64 sparc x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND="$(python_abi_depend net-zope/namespaces-zope[five])
	$(python_abi_depend net-zope/accesscontrol)
	$(python_abi_depend net-zope/extensionclass)
	$(python_abi_depend net-zope/transaction)
	$(python_abi_depend net-zope/zope.app.form)
	$(python_abi_depend net-zope/zope.browser)
	|| (
		$(python_abi_depend net-zope/zope.browsermenu)
		$(python_abi_depend net-zope/zope.app.publisher)
	)
	$(python_abi_depend net-zope/zope.component)
	$(python_abi_depend net-zope/zope.event)
	$(python_abi_depend net-zope/zope.formlib)
	$(python_abi_depend net-zope/zope.i18nmessageid)
	$(python_abi_depend net-zope/zope.interface)
	$(python_abi_depend net-zope/zope.lifecycleevent)
	$(python_abi_depend net-zope/zope.location)
	$(python_abi_depend net-zope/zope.publisher)
	$(python_abi_depend net-zope/zope.schema)"
DEPEND="${RDEPEND}
	app-arch/unzip
	$(python_abi_depend dev-python/setuptools)"

DOCS="CHANGES.txt README.txt"
PYTHON_MODULES="${PN/.//}"
