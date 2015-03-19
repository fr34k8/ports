# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_DEPEND="<<[{3.*-cpython *-pypy-*}sqlite]>>"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="*-jython"

inherit python

DESCRIPTION="Virtual for pysqlite2 and sqlite3 Python modules"
HOMEPAGE=""
SRC_URI=""

LICENSE=""
SLOT="0"
KEYWORDS="*"
IUSE="external"

DEPEND=""
RDEPEND="python_abis_2.6? (
		external? ( dev-python/pysqlite:2[python_abis_2.6] )
		!external? ( || ( dev-lang/python:2.6[sqlite] dev-python/pysqlite:2[python_abis_2.6] ) )
	)
	python_abis_2.7? (
		external? ( dev-python/pysqlite:2[python_abis_2.7] )
		!external? ( || ( dev-lang/python:2.7[sqlite] dev-python/pysqlite:2[python_abis_2.7] ) )
	)"
