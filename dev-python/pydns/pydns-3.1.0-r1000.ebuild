# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.*"
DISTUTILS_SRC_TEST="nosetests"

inherit distutils eutils

MY_PN="py3dns"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Python module for DNS (Domain Name Service)"
HOMEPAGE="http://pydns.sourceforge.net/ https://launchpad.net/py3dns https://pypi.python.org/pypi/py3dns"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="CNRI"
SLOT="3"
KEYWORDS="*"
IUSE="examples"

RDEPEND="$(python_abi_depend virtual/python-ipaddress)
	!dev-python/py3dns
	!dev-python/pydns:python-3"
DEPEND="${RDEPEND}
	virtual/libiconv"

S="${WORKDIR}/${MY_P}"

PYTHON_MODULES="DNS"

src_prepare() {
	distutils_src_prepare

	epatch "${FILESDIR}/${MY_P}-python-3.2.patch"

	# Clean documentation.
	mv CREDITS.txt CREDITS
	mv README.txt README
	rm README-guido.txt
}

src_install(){
	distutils_src_install

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins {tests,tools}/*.py
	fi
}
