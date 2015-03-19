# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.*"

inherit distutils eutils

MY_PN="IMDbPY"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Python package to access the IMDb's database"
HOMEPAGE="http://imdbpy.sourceforge.net/ https://pypi.python.org/pypi/IMDbPY"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

# Main license: GPL-2
# imdb/parser/http/bsouplxml/_bsoup.py: BSD
LICENSE="BSD GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="$(python_abi_depend dev-python/setuptools)"
RDEPEND=""

S="${WORKDIR}/${MY_PN}-${PV}"

DISTUTILS_GLOBAL_OPTIONS=("*-jython --without-cutils")
DOCS="docs/AUTHOR.txt docs/Changelog.txt docs/CONTRIBUTORS.txt docs/CREDITS.txt docs/FAQS.txt docs/README.* docs/TODO.txt"
PYTHON_MODULES="imdb"

src_prepare() {
	distutils_src_prepare
	epatch "${FILESDIR}/${PN}-4.6-data_location.patch"
}
