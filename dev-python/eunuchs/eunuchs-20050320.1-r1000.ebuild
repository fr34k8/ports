# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.* *-jython"

inherit distutils eutils

DESCRIPTION="Missing manly parts of UNIX API for Python"
HOMEPAGE="http://www.inoi.fi/open/trac/eunuchs https://pypi.python.org/pypi/python-eunuchs"
SRC_URI="mirror://debian/pool/main/e/${PN}/${PN}_${PV}.tar.gz"

LICENSE="LGPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND=""
RDEPEND=""

src_prepare() {
	distutils_src_prepare
	epatch "${FILESDIR}/${P}-python-2.5.patch"
}

src_test() {
	testing() {
		python_execute PYTHONPATH="$(ls -d build-${PYTHON_ABI}/lib.*)" "$(PYTHON)" examples/test-socketpair.py
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install

	docinto examples
	dodoc examples/*
}
