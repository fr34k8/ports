# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
PYTHON_RESTRICTED_ABIS="3.1 3.2 *-jython *-pypy"

inherit distutils

DESCRIPTION="Amazon Web Services Library"
HOMEPAGE="https://github.com/boto/boto https://pypi.python.org/pypi/boto"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="$(python_abi_depend virtual/python-argparse)"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)"

src_install() {
	distutils_src_install

	delete_tests() {
		find "${ED}$(python_get_sitedir)/boto" -name "test_*.py" -delete
	}
	python_execute_function -q delete_tests
}
