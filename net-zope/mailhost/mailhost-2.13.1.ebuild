# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="4-python"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.5 3.* *-jython *-pypy-*"

inherit distutils

MY_PN="Products.MailHost"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="zope.sendmail integration for Zope 2."
HOMEPAGE="http://pypi.python.org/pypi/Products.MailHost"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.zip"

LICENSE="ZPL"
SLOT="0"
KEYWORDS="amd64 ~ppc ~ppc64 sparc x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND="$(python_abi_depend net-zope/namespaces-zope[Products])
	$(python_abi_depend net-zope/accesscontrol)
	$(python_abi_depend net-zope/acquisition)
	$(python_abi_depend net-zope/datetime)
	$(python_abi_depend net-zope/documenttemplate)
	$(python_abi_depend net-zope/persistence)
	$(python_abi_depend net-zope/zope)
	$(python_abi_depend net-zope/zope.deferredimport)
	$(python_abi_depend net-zope/zope.interface)
	$(python_abi_depend net-zope/zope.sendmail)"
DEPEND="${RDEPEND}
	app-arch/unzip
	$(python_abi_depend dev-python/setuptools)"

S="${WORKDIR}/${MY_P}"

DOCS="CHANGES.txt README.txt"
PYTHON_MODULES="${MY_PN/.//}"
