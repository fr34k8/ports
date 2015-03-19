# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.* *-jython *-pypy-*"

inherit distutils eutils

MY_P="pyFltk-${PV}"

DESCRIPTION="Python interface to Fltk library"
HOMEPAGE="http://pyfltk.sourceforge.net/"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="doc"

DEPEND=">=x11-libs/fltk-1.3.0:1=[opengl]"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

PYTHON_CXXFLAGS=("2.* + -fno-strict-aliasing")

DOCS="CHANGES README TODO"
PYTHON_MODULES="fltk"

src_prepare() {
	distutils_src_prepare
	epatch "${FILESDIR}/${P}-linux-3.x-detection.patch"

	# Disable installation of documentation and tests.
	sed -e "/package_data=/d" -i setup.py || die "sed failed"
}

src_install() {
	distutils_src_install

	if use doc; then
		dohtml -r fltk/docs/
	fi
}
