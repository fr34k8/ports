# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"

inherit distutils

DESCRIPTION="ASN.1 types and codecs"
HOMEPAGE="http://pyasn1.sourceforge.net/ https://pypi.python.org/pypi/pyasn1"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="*"
IUSE="test"

DEPEND="$(python_abi_depend dev-python/setuptools)
	test? ( $(python_abi_depend -i "2.6 3.1" dev-python/unittest2) )"
RDEPEND=""

DOCS="CHANGES README THANKS TODO"

src_test() {
	testing() {
		python_execute PYTHONPATH="build-${PYTHON_ABI}/lib:." "$(PYTHON)" test/suite.py
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install
	dohtml doc/*
}
