# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.*"

inherit distutils

DESCRIPTION="A framework for writing long-running, high-performance network servers in Python, using asynchronous sockets"
HOMEPAGE="https://pypi.python.org/pypi/medusa"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="PSF-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

DOCS="CHANGES.txt docs/*.txt"

src_install() {
	distutils_src_install

	dohtml docs/*.html docs/*.gif
	insinto /usr/share/doc/${PF}/examples
	doins -r demo/*
}
