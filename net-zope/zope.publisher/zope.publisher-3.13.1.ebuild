# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="4-python"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.5 3.* *-jython *-pypy-*"

inherit distutils

DESCRIPTION="The Zope publisher publishes Python objects on the web."
HOMEPAGE="http://pypi.python.org/pypi/zope.publisher"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.zip"

LICENSE="ZPL"
SLOT="0"
KEYWORDS="amd64 ~ppc ~ppc64 sparc x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND="$(python_abi_depend net-zope/namespaces-zope[zope])
	$(python_abi_depend dev-python/setuptools)
	$(python_abi_depend net-zope/zope.browser)
	$(python_abi_depend net-zope/zope.component)
	$(python_abi_depend net-zope/zope.configuration)
	$(python_abi_depend net-zope/zope.contenttype)
	$(python_abi_depend net-zope/zope.event)
	$(python_abi_depend net-zope/zope.exceptions)
	$(python_abi_depend net-zope/zope.i18n)
	$(python_abi_depend net-zope/zope.interface)
	$(python_abi_depend net-zope/zope.location)
	$(python_abi_depend net-zope/zope.proxy)
	$(python_abi_depend net-zope/zope.schema)
	$(python_abi_depend net-zope/zope.security)"
DEPEND="${RDEPEND}
	app-arch/unzip"

DOCS="CHANGES.txt README.txt"
PYTHON_MODULES="${PN/.//}"
