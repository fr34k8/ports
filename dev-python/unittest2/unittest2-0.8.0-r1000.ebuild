# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="3.1 *-jython"

inherit distutils

DESCRIPTION="The new features in unittest backported to Python 2.6+."
HOMEPAGE="https://code.google.com/p/unittest-ext/ https://hg.python.org/unittest2 https://pypi.python.org/pypi/unittest2"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="$(python_abi_depend dev-python/setuptools)
	$(python_abi_depend dev-python/six)
	$(python_abi_depend virtual/python-argparse)"
RDEPEND="${DEPEND}"

DOCS="README.txt"

src_prepare() {
	distutils_src_prepare

	# https://code.google.com/p/unittest-ext/issues/detail?id=88
	sed -e "s/REQUIRES = \['argparse', 'six'\],/REQUIRES = ['six']\nif sys.version_info[:2] < (2, 7) or (3, 0) <= sys.version_info[:2] < (3, 2):\n    REQUIRES.append('argparse')/" -i setup.py
}

src_compile() {
	distutils_src_compile

	preparation() {
		if has "$(python_get_version -l)" 3.1; then
			2to3-${PYTHON_ABI} -f callable -nw --no-diffs build-${PYTHON_ABI}/lib
		fi
	}
	python_execute_function -q preparation
}

src_test() {
	testing() {
		pushd build-${PYTHON_ABI}/lib > /dev/null
		python_execute "$(PYTHON)" -c 'import unittest2.__main__; unittest2.__main__.main_()' || return
		popd > /dev/null
	}
	python_execute_function testing
}
