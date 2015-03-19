# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"

inherit distutils

DESCRIPTION="Better living through Python with decorators"
HOMEPAGE="https://pypi.python.org/pypi/decorator http://code.google.com/p/micheles/"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="$(python_abi_depend dev-python/setuptools)"
RDEPEND=""

DOCS="README.txt"
PYTHON_MODULES="decorator.py"

src_test() {
	testing() {
		if [[ "$(python_get_version -l --major)" == "3" ]]; then
			python_execute PYTHONPATH="build-${PYTHON_ABI}/lib" "$(PYTHON)" documentation3.py
		else
			python_execute PYTHONPATH="build-${PYTHON_ABI}/lib" "$(PYTHON)" documentation.py
		fi
	}
	python_execute_function testing
}
