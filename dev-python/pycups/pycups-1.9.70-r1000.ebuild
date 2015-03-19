# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
PYTHON_RESTRICTED_ABIS="3.1 3.2 *-jython"

inherit distutils

DESCRIPTION="Python bindings for libcups"
HOMEPAGE="http://cyberelk.net/tim/software/pycups/ https://pypi.python.org/pypi/pycups"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="doc examples"
REQUIRED_USE="doc? ( python_abis_2.7 )"

RDEPEND="net-print/cups"
DEPEND="${RDEPEND}
	doc? ( dev-python/epydoc[python_abis_2.7] )"

PYTHON_CFLAGS=("2.* + -fno-strict-aliasing")

src_compile() {
	distutils_src_compile

	if use doc; then
		einfo "Generation of documentation"
		epydoc-2.7 --html -o html build-2.7/lib*/cups.so || die "Generation of documentation failed"
	fi
}

src_install() {
	distutils_src_install

	if use doc; then
		dohtml -r html/
	fi

	if use examples; then
		insinto /usr/share/doc/${PF}
		doins -r examples/
	fi
}
