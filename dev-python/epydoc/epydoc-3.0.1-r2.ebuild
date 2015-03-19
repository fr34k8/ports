# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
PYTHON_DEPEND="<<>> X? ( <<[{*-cpython}tk]>> )"
PYTHON_RESTRICTED_ABIS="3.*"

inherit distutils eutils

DESCRIPTION="Tool for generating API documentation for Python modules, based on their docstrings"
HOMEPAGE="http://epydoc.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="X doc latex"

DEPEND="$(python_abi_depend dev-python/docutils)
	latex? (
		dev-texlive/texlive-latexextra
		virtual/latex-base
	)"
RDEPEND="${DEPEND}"

src_prepare() {
	distutils_src_prepare
	epatch "${FILESDIR}/${P}-docutils-0.6.patch"
	epatch "${FILESDIR}/${P}-python-2.6.patch"
}

src_install() {
	distutils_src_install

	doman man/*
	if use doc; then
		dohtml -r doc/*
	fi
	use X || rm -f "${ED}usr/bin/epydocgui"*
}
