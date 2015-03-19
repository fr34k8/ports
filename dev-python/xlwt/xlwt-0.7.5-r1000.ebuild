# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.*"

inherit distutils

DESCRIPTION="Library to create spreadsheet files compatible with MS Excel 97/2000/XP/2003 XLS files"
HOMEPAGE="http://www.python-excel.org/ https://github.com/python-excel/xlwt https://pypi.python.org/pypi/xlwt"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="examples"

DEPEND=""
RDEPEND=""

src_prepare() {
	distutils_src_prepare

	# Do not install documentation and examples in site-packages directories.
	sed -e "/package_data/,+6d" -i setup.py || die "sed failed"
}

src_install() {
	distutils_src_install

	dohtml -r xlwt/doc/
	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins xlwt/examples/*
	fi
}
