# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
# Avoid collisions with python-2 slot.
PYTHON_RESTRICTED_ABIS="2.*"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="3.3 3.4"

inherit distutils eutils

MY_PN="BeautifulSoup"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="HTML/XML parser for quick-turnaround applications like screen-scraping."
HOMEPAGE="http://www.crummy.com/software/BeautifulSoup/ https://launchpad.net/beautifulsoup https://pypi.python.org/pypi/BeautifulSoup"
SRC_URI="http://www.crummy.com/software/BeautifulSoup/bs3/download/3.1.x/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="python-3"
KEYWORDS="*"
IUSE=""

DEPEND=""
RDEPEND=""

S="${WORKDIR}/${MY_P}"

PYTHON_MODULES="BeautifulSoup.py BeautifulSoupTests.py"

src_prepare() {
	distutils_src_prepare
	epatch "${FILESDIR}/${P}-python-3.patch"
}

src_test() {
	testing() {
		python_execute PYTHONPATH="build-${PYTHON_ABI}/lib" "$(PYTHON)" BeautifulSoupTests.py
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install

	# Delete useless files.
	rm -fr "${ED}usr/bin"
}
