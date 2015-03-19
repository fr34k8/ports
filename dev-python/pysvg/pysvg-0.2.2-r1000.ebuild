# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="4-python"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.* *-jython"

inherit distutils

DESCRIPTION="Python SVG Library"
HOMEPAGE="http://codeboje.de/pysvg/ http://code.google.com/p/pysvg/ http://pypi.python.org/pypi/pysvg"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.zip"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="doc"

DEPEND="app-arch/unzip
	$(python_abi_depend dev-python/setuptools)"
RDEPEND=""

src_install() {
	distutils_src_install

	if use doc; then
		dohtml -r doc/html/
	fi
}
