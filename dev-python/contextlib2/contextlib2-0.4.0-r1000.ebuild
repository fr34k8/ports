# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"

inherit distutils

DESCRIPTION="Backports and enhancements for the contextlib module"
HOMEPAGE="https://contextlib2.readthedocs.org/ https://pypi.python.org/pypi/contextlib2"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="PSF-2"
SLOT="0"
KEYWORDS="*"
IUSE="test"

DEPEND="test? ( $(python_abi_depend -i "2.6" dev-python/unittest2) )"
RDEPEND=""

DOCS="NEWS.rst README.txt"
PYTHON_MODULES="contextlib2.py"

src_test() {
	testing() {
		python_execute PYTHONPATH="build-${PYTHON_ABI}/lib" "$(PYTHON)" test_contextlib2.py
	}
	python_execute_function testing
}
