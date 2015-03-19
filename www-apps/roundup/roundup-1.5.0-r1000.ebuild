# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.* *-jython"

inherit distutils

DESCRIPTION="Simple-to-use and -install issue-tracking system with command-line, web, and e-mail interfaces"
HOMEPAGE="http://roundup.sourceforge.net/ https://pypi.python.org/pypi/roundup"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT ZPL"
SLOT="0"
KEYWORDS="*"
IUSE="chameleon mysql postgres sqlite ssl timezone xapian"

DEPEND="chameleon? ( $(python_abi_depend dev-python/chameleon) )
	mysql? ( $(python_abi_depend dev-python/mysql-python) )
	postgres? ( $(python_abi_depend -e "*-pypy-*" dev-python/psycopg:2) )
	sqlite? ( $(python_abi_depend virtual/python-sqlite) )
	ssl? ( $(python_abi_depend dev-python/pyopenssl) )
	timezone? ( $(python_abi_depend dev-python/pytz) )
	xapian? ( $(python_abi_depend -e "*-pypy-*" dev-libs/xapian-bindings[python]) )"
RDEPEND="${DEPEND}"

DOCS="CHANGES.txt doc/*.txt"

src_install() {
	distutils_src_install
	rm -fr "${ED}usr/share/doc/${PN}"
	dohtml -r doc/
}
