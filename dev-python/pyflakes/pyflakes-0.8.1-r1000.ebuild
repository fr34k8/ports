# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="*-jython"
DISTUTILS_SRC_TEST="setup.py"

inherit distutils eutils

DESCRIPTION="Passive checker of Python programs"
HOMEPAGE="https://launchpad.net/pyflakes https://pypi.python.org/pypi/pyflakes"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="$(python_abi_depend dev-python/setuptools)"
RDEPEND="${DEPEND}"

DOCS="AUTHORS NEWS.txt"

src_prepare() {
	distutils_src_prepare
	epatch "${FILESDIR}/${P}-python-3.1.patch"
}

src_install() {
	distutils_src_install

	delete_tests() {
		rm -r "${ED}$(python_get_sitedir)/pyflakes/test"
	}
	python_execute_function -q delete_tests
}
