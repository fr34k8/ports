# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="4-python"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.* *-jython *-pypy-*"

inherit distutils eutils

DESCRIPTION="A python wrapper for Gnuplot"
HOMEPAGE="http://gnuplot-py.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="amd64 ~ia64 ~ppc ~ppc64 ~s390 sparc x86 ~x86-fbsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos"
IUSE="doc"

DEPEND="$(python_abi_depend dev-python/numpy)
	sci-visualization/gnuplot"
RDEPEND="${DEPEND}"

DOCS="ANNOUNCE.txt CREDITS.txt FAQ.txt NEWS.txt TODO.txt"
PYTHON_MODULES="Gnuplot"

src_prepare() {
	distutils_src_prepare
	epatch "${FILESDIR}/${PN}-1.7-mousesupport.patch"
	python_convert_shebangs 2 demo.py test.py
}

src_install() {
	distutils_src_install

	delete_examples() {
		rm -f "${ED}$(python_get_sitedir)/Gnuplot/"{demo,test}.py
	}
	python_execute_function -q delete_examples

	insinto /usr/share/doc/${PF}/examples
	doins demo.py test.py

	if use doc; then
		insinto /usr/share/doc/${PF}/html
		doins -r doc/Gnuplot/*
	fi
}
