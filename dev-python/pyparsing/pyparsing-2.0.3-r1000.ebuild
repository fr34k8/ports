# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"

inherit distutils

DESCRIPTION="Python parsing module"
HOMEPAGE="http://pyparsing.wikispaces.com/ https://pypi.python.org/pypi/pyparsing"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="doc examples"

DEPEND=""
RDEPEND=""

PYTHON_MODULES="pyparsing.py"

src_install() {
	distutils_src_install

	dohtml HowToUsePyparsing.html

	if use doc; then
		dodoc docs/*.pdf
		dohtml -r htmldoc/
	fi

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins examples/*
	fi
}
