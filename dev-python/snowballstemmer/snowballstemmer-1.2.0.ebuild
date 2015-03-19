# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"

inherit distutils

DESCRIPTION="Snowball stemming library collection for Python"
HOMEPAGE="https://github.com/shibukawa/snowball_py https://pypi.python.org/pypi/snowballstemmer"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="$(python_abi_depend -e "*-jython" dev-python/pystemmer)"
RDEPEND="${DEPEND}"

src_compile() {
	distutils_src_compile

	preparation() {
		if has "$(python_get_version -l)" 3.1 3.2; then
			2to3-${PYTHON_ABI} -f unicode -nw --no-diffs build-${PYTHON_ABI}/lib
		fi
	}
	python_execute_function -q preparation
}
