# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="*-jython"
DISTUTILS_SRC_TEST="nosetests"

inherit distutils toolchain-funcs

DESCRIPTION="A library to allow customization of the process title."
HOMEPAGE="http://code.google.com/p/py-setproctitle/ https://pypi.python.org/pypi/setproctitle"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND=""
RDEPEND=""

DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES="1"
DOCS="HISTORY.rst README.rst"

src_prepare() {
	python_copy_sources

	preparation() {
		if [[ "$(python_get_version -l --major)" == "3" ]]; then
			2to3-${PYTHON_ABI} -nw --no-diffs tests
		fi
	}
	python_execute_function -s preparation
}

distutils_src_test_pre_hook() {
	ln -fs pyrun-${PYTHON_ABI} tests/pyrun$(python_get_version -l --major)
}

src_test() {
	build_pyrun() {
		python_execute $(tc-getCC) ${CPPFLAGS} ${CFLAGS} ${LDFLAGS} -I$(python_get_includedir) -o tests/pyrun-${PYTHON_ABI} tests/pyrun.c $(python_get_library -l)
	}
	python_execute_function -q -s build_pyrun

	distutils_src_test
}
