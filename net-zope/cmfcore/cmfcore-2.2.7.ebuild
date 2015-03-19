# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.5 3.* *-jython *-pypy-*"

inherit distutils

MY_PN="Products.CMFCore"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Zope Content Management Framework core components"
HOMEPAGE="https://launchpad.net/zope-cmf http://pypi.python.org/pypi/Products.CMFCore"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="ZPL"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="$(python_abi_depend net-zope/namespaces-zope[Products])
	$(python_abi_depend net-zope/accesscontrol)
	$(python_abi_depend net-zope/acquisition)
	$(python_abi_depend net-zope/btreefolder2)
	$(python_abi_depend net-zope/datetime)
	$(python_abi_depend net-zope/documenttemplate)
	$(python_abi_depend net-zope/extensionclass)
	$(python_abi_depend net-zope/five.localsitemanager)
	$(python_abi_depend net-zope/genericsetup)
	$(python_abi_depend net-zope/mailhost)
	$(python_abi_depend net-zope/persistence)
	$(python_abi_depend net-zope/pythonscripts)
	$(python_abi_depend net-zope/zcatalog)
	$(python_abi_depend net-zope/zexceptions)
	$(python_abi_depend net-zope/zodb)
	$(python_abi_depend net-zope/zope)
	$(python_abi_depend net-zope/zope.component)
	$(python_abi_depend net-zope/zope.configuration)
	$(python_abi_depend net-zope/zope.container)
	$(python_abi_depend net-zope/zope.contenttype)
	$(python_abi_depend net-zope/zope.dottedname)
	$(python_abi_depend net-zope/zope.event)
	$(python_abi_depend net-zope/zope.i18nmessageid)
	$(python_abi_depend net-zope/zope.interface)
	$(python_abi_depend net-zope/zope.lifecycleevent)
	$(python_abi_depend net-zope/zope.publisher)
	$(python_abi_depend net-zope/zope.schema)
	$(python_abi_depend net-zope/zope.structuredtext)
	$(python_abi_depend net-zope/zope.testing)
	$(python_abi_depend net-zope/zope.traversing)
	$(python_abi_depend net-zope/zsqlmethods)"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)"

S="${WORKDIR}/${MY_P}"

DOCS="Products/CMFCore/CHANGES.txt Products/CMFCore/README.txt"
PYTHON_MODULES="${MY_PN/.//}"

src_prepare() {
	distutils_src_prepare

	# Don't require eggtestinfo.
	sed -e "s/'eggtestinfo',//" -i setup.py
}

pkg_postinst() {
	python_mod_optimize -x /tests/ ${MY_PN/.//}
}
