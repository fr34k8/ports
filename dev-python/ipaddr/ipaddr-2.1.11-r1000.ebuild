# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"

inherit distutils

DESCRIPTION="Python IP address manipulation library"
HOMEPAGE="http://code.google.com/p/ipaddr-py/ https://pypi.python.org/pypi/ipaddr"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND=""
RDEPEND=""

DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES="1"
DOCS="README RELEASENOTES"
PYTHON_MODULES="ipaddr.py"

src_prepare() {
	distutils_src_prepare

	preparation() {
		if [[ "$(python_get_version -l --major)" == "3" ]]; then
			2to3-${PYTHON_ABI} -nw --no-diffs ipaddr.py ipaddr_test.py
		fi
	}
	python_execute_function -s preparation
}

src_test() {
	testing() {
		python_execute PYTHONPATH="build/lib" "$(PYTHON)" ipaddr_test.py
	}
	python_execute_function -s testing
}
