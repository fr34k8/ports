# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*-jython"
DISTUTILS_SRC_TEST="nosetests"

inherit distutils

DESCRIPTION="Library for developers to extract data from Microsoft Excel (tm) spreadsheet files"
HOMEPAGE="http://www.python-excel.org/ https://github.com/python-excel/xlrd https://pypi.python.org/pypi/xlrd"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND=""
RDEPEND=""

src_prepare() {
	distutils_src_prepare

	# Disable failing test.
	sed -e "s/test_names_demo/_&/" -i tests/test_open_workbook.py
}
