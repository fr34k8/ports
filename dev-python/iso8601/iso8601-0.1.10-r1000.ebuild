# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
DISTUTILS_SRC_TEST="py.test"

inherit distutils

DESCRIPTION="Simple module to parse ISO 8601 dates"
HOMEPAGE="https://bitbucket.org/micktwomey/pyiso8601 https://pypi.python.org/pypi/iso8601"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="$(python_abi_depend dev-python/setuptools)"
RDEPEND=""

src_test() {
	python_execute_py.test iso8601
}

src_install() {
	distutils_src_install

	delete_tests() {
		rm "${ED}$(python_get_sitedir)/iso8601/test_iso8601.py"
	}
	python_execute_function -q delete_tests
}
