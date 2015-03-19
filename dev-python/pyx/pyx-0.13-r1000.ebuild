# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.* 3.1 *-jython"

inherit distutils

MY_PN="PyX"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Python package for the generation of PostScript and PDF files"
HOMEPAGE="http://pyx.sourceforge.net/ https://pypi.python.org/pypi/PyX"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="doc"

RDEPEND="virtual/tex-base"
DEPEND="${RDEPEND}
	doc? ( virtual/latex-base )"

S="${WORKDIR}/${MY_P}"

DOCS="AUTHORS CHANGES"

src_prepare() {
	distutils_src_prepare

	sed \
		-e "s/^build_t1code=.*/build_t1code=1/" \
		-e "s/^build_pykpathsea=.*/build_pykpathsea=1/" \
		-i setup.cfg || die "sed failed"
}

src_compile() {
	distutils_src_compile

	if use doc; then
		einfo "Generation of documentation"
		pushd faq > /dev/null
		VARTEXFONTS="${T}/fonts" emake latexpdf
		popd > /dev/null
	fi
}

src_install() {
	distutils_src_install

	if use doc; then
		dodoc faq/_build/latex/pyxfaq.pdf
	fi
}
