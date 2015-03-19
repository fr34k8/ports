# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_DEPEND="<<[{*-cpython}xml]>>"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*-jython"
DISTUTILS_SRC_TEST="nosetests"

inherit distutils eutils

DESCRIPTION="A Python module to deal with freedesktop.org specifications"
HOMEPAGE="http://freedesktop.org/wiki/Software/pyxdg http://cgit.freedesktop.org/xdg/pyxdg/ https://pypi.python.org/pypi/pyxdg"
SRC_URI="http://people.freedesktop.org/~takluyver/${P}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="test"

RDEPEND="x11-misc/shared-mime-info"
DEPEND="${RDEPEND}
	test? ( x11-themes/hicolor-icon-theme )"

DOCS="AUTHORS ChangeLog README TODO"
PYTHON_MODULES="xdg"

src_prepare() {
	distutils_src_prepare
	epatch "${FILESDIR}/${P}-CVE-2014-1624.patch"
}
