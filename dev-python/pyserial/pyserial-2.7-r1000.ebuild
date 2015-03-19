# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"

inherit distutils

DESCRIPTION="Python Serial Port Extension"
HOMEPAGE="http://pyserial.sourceforge.net/ http://sourceforge.net/projects/pyserial/ https://pypi.python.org/pypi/pyserial"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="PSF-2"
SLOT="0"
KEYWORDS="*"
IUSE="doc examples"

DEPEND="doc? ( $(python_abi_depend dev-python/sphinx) )"
RDEPEND=""

DOCS="CHANGES.txt README.txt"
PYTHON_MODULES="serial"

src_compile() {
	distutils_src_compile

	if use doc; then
		einfo "Generation of documentation"
		pushd documentation > /dev/null
		emake html
		popd > /dev/null
	fi
}

src_install() {
	distutils_src_install

	if use doc; then
		dohtml -r documentation/_build/html/
	fi

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins examples/*
	fi
}
