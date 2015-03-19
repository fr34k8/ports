# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.*"

inherit distutils

DESCRIPTION="Jon's Python modules"
HOMEPAGE="http://jonpy.sourceforge.net/ https://pypi.python.org/pypi/jonpy"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="doc examples"

DEPEND=""
RDEPEND=""

PYTHON_MODULES="jon"

src_install() {
	distutils_src_install

	if use doc; then
		dohtml doc/*
	fi

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins -r example/{*,.[^.]*}
	fi
}
