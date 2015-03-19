# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.*"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*-jython"

inherit distutils

MY_PN="BeautifulSoup"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="HTML/XML parser for quick-turnaround applications like screen-scraping."
HOMEPAGE="http://www.crummy.com/software/BeautifulSoup/ https://launchpad.net/beautifulsoup https://pypi.python.org/pypi/BeautifulSoup"
SRC_URI="http://www.crummy.com/software/BeautifulSoup/bs3/download/3.x/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="python-2"
KEYWORDS="*"
IUSE=""

DEPEND=""
RDEPEND=""

S="${WORKDIR}/${MY_P}"

PYTHON_MODULES="BeautifulSoup.py BeautifulSoupTests.py"

src_test() {
	testing() {
		python_execute PYTHONPATH="build-${PYTHON_ABI}/lib" "$(PYTHON)" BeautifulSoupTests.py
	}
	python_execute_function testing
}
