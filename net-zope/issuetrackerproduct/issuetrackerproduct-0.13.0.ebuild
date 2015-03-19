# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="4-python"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.5 3.* *-jython *-pypy-*"

inherit python

MY_PN="IssueTrackerProduct"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="A user-friendly issue tracker web application for Zope"
HOMEPAGE="http://www.issuetrackerproduct.com/"
SRC_URI="http://www.issuetrackerproduct.com/Download/${MY_P}.tgz"

LICENSE="ZPL"
SLOT="0"
KEYWORDS="amd64 ~ppc ~ppc64 sparc x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux"
IUSE=""

DEPEND="$(python_abi_depend net-zope/namespaces-zope[Products])
	$(python_abi_depend dev-python/simplejson)
	$(python_abi_depend dev-python/stripogram)
	$(python_abi_depend net-zope/accesscontrol)
	$(python_abi_depend net-zope/acquisition)
	$(python_abi_depend net-zope/datetime)
	$(python_abi_depend net-zope/persistence)
	$(python_abi_depend net-zope/transaction)
	$(python_abi_depend net-zope/zcatalog)
	$(python_abi_depend net-zope/zexceptions)
	$(python_abi_depend net-zope/zlog)
	$(python_abi_depend net-zope/zodb)
	$(python_abi_depend net-zope/zope)
	$(python_abi_depend net-zope/zope.contenttype)
	$(python_abi_depend net-zope/zope.structuredtext)"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_PN}"

src_install() {
	installation() {
		insinto $(python_get_sitedir)/Products/${MY_PN}
		doins -r *
	}
	python_execute_function installation

	dodoc CHANGES.txt README.txt TODO.txt
}

pkg_postinst() {
	python_mod_optimize -x /www/ Products/${MY_PN}
}

pkg_postrm() {
	python_mod_cleanup Products/${MY_PN}
}
