# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="4-python"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.* *-jython"

inherit distutils

DESCRIPTION="An emacs mode for using rope python refactoring library"
HOMEPAGE="http://rope.sourceforge.net/ropemacs.html http://pypi.python.org/pypi/ropemacs"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="$(python_abi_depend ">=dev-python/rope-0.9.4")
	$(python_abi_depend ">=dev-python/ropemode-0.2")"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)"

DOCS="docs/*.txt"

pkg_postinst() {
	distutils_pkg_postinst

	elog "In order to enable ropemacs support in Emacs, install"
	elog "app-emacs/pymacs and add the following line to your ~/.emacs file:"
	elog "  (pymacs-load \"ropemacs\" \"rope-\")"
}
