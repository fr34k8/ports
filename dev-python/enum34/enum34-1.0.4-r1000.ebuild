# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
PYTHON_RESTRICTED_ABIS="3.[4-9]"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*-jython"

inherit distutils

DESCRIPTION="Python 3.4 Enum backported to 3.3, 3.2, 3.1, 2.7, 2.6, 2.5, and 2.4"
HOMEPAGE="https://pypi.python.org/pypi/enum34"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="$(python_abi_depend -i "2.6" dev-python/ordereddict)"
RDEPEND="${DEPEND}"

DOCS="enum/doc/enum.rst"
PYTHON_MODULES="enum"

src_prepare() {
	distutils_src_prepare

	# Use ordereddict.OrderedDict with Python 2.6.
	sed -e "s/OrderedDict = None/from ordereddict import OrderedDict/" -i enum/*.py
}

src_test() {
	testing() {
		python_execute "$(PYTHON)" enum/test_enum.py
	}
	python_execute_function testing
}
