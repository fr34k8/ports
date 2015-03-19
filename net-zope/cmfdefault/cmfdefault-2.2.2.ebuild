# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="4-python"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.5 3.* *-jython *-pypy-*"

inherit distutils

MY_PN="Products.CMFDefault"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Default product for the Zope Content Management Framework"
HOMEPAGE="https://launchpad.net/zope-cmf http://pypi.python.org/pypi/Products.CMFDefault"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="ZPL"
SLOT="0"
KEYWORDS="amd64 ~ppc ~ppc64 sparc x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND="$(python_abi_depend net-zope/namespaces-zope[Products])
	$(python_abi_depend net-zope/accesscontrol)
	$(python_abi_depend net-zope/acquisition)
	$(python_abi_depend net-zope/cmfcore)
	$(python_abi_depend net-zope/datetime)
	$(python_abi_depend net-zope/documenttemplate)
	$(python_abi_depend net-zope/five.formlib)
	$(python_abi_depend net-zope/five.localsitemanager)
	$(python_abi_depend net-zope/genericsetup)
	$(python_abi_depend net-zope/mailhost)
	$(python_abi_depend net-zope/persistence)
	$(python_abi_depend net-zope/pythonscripts)
	$(python_abi_depend net-zope/transaction)
	$(python_abi_depend ">=net-zope/zope-2.12.3")
	$(python_abi_depend net-zope/zope.app.form)
	$(python_abi_depend net-zope/zope.app.locales)
	$(python_abi_depend net-zope/zope.component)
	$(python_abi_depend net-zope/zope.container)
	$(python_abi_depend net-zope/zope.datetime)
	$(python_abi_depend net-zope/zope.dottedname)
	$(python_abi_depend net-zope/zope.formlib)
	$(python_abi_depend net-zope/zope.i18n)
	$(python_abi_depend net-zope/zope.i18nmessageid)
	$(python_abi_depend net-zope/zope.interface)
	$(python_abi_depend net-zope/zope.publisher)
	$(python_abi_depend net-zope/zope.schema)
	$(python_abi_depend net-zope/zope.site)
	$(python_abi_depend net-zope/zope.structuredtext)"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)"

S="${WORKDIR}/${MY_P}"

DOCS="Products/CMFDefault/CHANGES.txt Products/CMFDefault/README.txt"
PYTHON_MODULES="${MY_PN/.//}"

src_prepare() {
	distutils_src_prepare

	# Don't require eggtestinfo.
	sed -e "s/'eggtestinfo',//" -i setup.py
}

pkg_postinst() {
	python_mod_optimize -x /skins/ ${MY_PN/.//}
}
