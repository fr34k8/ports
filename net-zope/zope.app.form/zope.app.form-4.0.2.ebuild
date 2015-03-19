# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="4-python"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.5 3.* *-jython *-pypy-*"

inherit distutils

DESCRIPTION="The Original Zope 3 Form Framework"
HOMEPAGE="http://pypi.python.org/pypi/zope.app.form"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="ZPL"
SLOT="0"
KEYWORDS="amd64 ~ppc ~ppc64 sparc x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND="$(python_abi_depend net-zope/namespaces-zope[zope,zope.app])
	$(python_abi_depend net-zope/transaction)
	$(python_abi_depend net-zope/zope.browser)
	$(python_abi_depend net-zope/zope.browsermenu)
	$(python_abi_depend net-zope/zope.browserpage)
	$(python_abi_depend net-zope/zope.component)
	$(python_abi_depend net-zope/zope.configuration)
	$(python_abi_depend net-zope/zope.datetime)
	$(python_abi_depend net-zope/zope.event)
	$(python_abi_depend net-zope/zope.exceptions)
	$(python_abi_depend ">=net-zope/zope.formlib-4.0")
	$(python_abi_depend net-zope/zope.i18n)
	$(python_abi_depend net-zope/zope.interface)
	$(python_abi_depend net-zope/zope.lifecycleevent)
	$(python_abi_depend net-zope/zope.proxy)
	$(python_abi_depend net-zope/zope.publisher)
	$(python_abi_depend net-zope/zope.schema)
	$(python_abi_depend net-zope/zope.security)"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)"

DOCS="CHANGES.txt README.txt"
PYTHON_MODULES="${PN//.//}"
