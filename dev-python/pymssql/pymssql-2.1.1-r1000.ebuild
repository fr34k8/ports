# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
PYTHON_RESTRICTED_ABIS="3.1 *-jython"

inherit distutils

DESCRIPTION="DB-API interface to Microsoft SQL Server for Python"
HOMEPAGE="http://pymssql.org/ https://code.google.com/p/pymssql/ https://github.com/pymssql/pymssql https://pypi.python.org/pypi/pymssql"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND=">=dev-db/freetds-0.82[mssql]"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/cython)
	$(python_abi_depend dev-python/setuptools)"

PYTHON_CFLAGS=("2.* + -fno-strict-aliasing")

DOCS="ChangeLog"

src_prepare() {
	distutils_src_prepare

	# Require not setuptools-git.
	sed -e "/setup_requires=\['setuptools_git'\]/d" -i setup.py

	# Force regeneration of Cython-generated files.
	rm _mssql.c pymssql.c

	# Delete internal copy of dev-db/freetds.
	rm -r freetds
}
