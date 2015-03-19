# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_DEPEND="<<[sqlite?]>>"
PYTHON_ABI_TYPE="multiple"
PYTHON_RESTRICTED_ABIS="3.* *-jython"

inherit distutils

MY_PN="SQLObject"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Object-Relational Manager, aka database wrapper"
HOMEPAGE="http://sqlobject.org/ https://pypi.python.org/pypi/SQLObject"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"
IUSE="mysql postgres sqlite"

RDEPEND="$(python_abi_depend dev-python/formencode)
	mysql? ( $(python_abi_depend dev-python/mysql-python) )
	postgres? ( $(python_abi_depend -e "*-pypy" dev-python/psycopg:2) )"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)"

S="${WORKDIR}/${MY_P}"

DOCS="README.txt docs/*.txt"
