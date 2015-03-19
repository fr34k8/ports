# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.*"

inherit distutils

DESCRIPTION="Utilities for handling IEEE 754 floating point special values"
HOMEPAGE="https://pypi.python.org/pypi/fpconst http://sourceforge.net/projects/rsoap/files/"
SRC_URI="mirror://sourceforge/rsoap/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND=""
RDEPEND=""

DOCS="pep-0754.txt"
PYTHON_MODULES="fpconst.py"

src_test() {
	testing() {
		python_execute PYTHONPATH="build-${PYTHON_ABI}/lib" "$(PYTHON)" -m fpconst
	}
	python_execute_function testing
}
