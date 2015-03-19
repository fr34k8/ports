# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*-jython"
DISTUTILS_SRC_TEST="nosetests"

inherit distutils

DESCRIPTION="C parser in Python"
HOMEPAGE="https://github.com/eliben/pycparser https://pypi.python.org/pypi/pycparser"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="$(python_abi_depend dev-python/ply:=)"
RDEPEND="${DEPEND}"

src_prepare() {
	distutils_src_prepare

	# Use system version of dev-python/ply.
	sed -e "s/\(from \)\.\(ply\(\.[^ ]\+\)\? import \)/\1\2/" -i pycparser/*.py
	rm -r pycparser/ply

	# Disable installation of deleted internal copy of dev-python/ply.
	sed -e "/^[[:space:]]*packages=/s/, 'pycparser.ply'//" -i setup.py
}

distutils_src_compile_post_hook() {
	pushd build-${PYTHON_ABI}/lib/pycparser > /dev/null
	python_execute "$(PYTHON)" _build_tables.py
	popd > /dev/null
}
