# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="4-python"
PYTHON_DEPEND="<<[tk]>>"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.* *-jython *-pypy-*"

inherit distutils

DESCRIPTION="Python refactoring IDE"
HOMEPAGE="http://rope.sourceforge.net/ropeide.html http://pypi.python.org/pypi/ropeide"
SRC_URI="mirror://sourceforge/rope/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="doc"

DEPEND="$(python_abi_depend ">=dev-python/rope-0.8.4")"
RDEPEND="${DEPEND}"

src_install() {
	distutils_src_install

	if use doc; then
		dodoc docs/*.txt
	fi
}
