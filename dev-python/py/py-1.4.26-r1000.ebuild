# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
# https://bitbucket.org/hpk42/py/issue/10
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*-jython"
DISTUTILS_SRC_TEST="py.test"

inherit distutils

DESCRIPTION="library with cross-python path, ini-parsing, io, code, log facilities"
HOMEPAGE="https://pylib.readthedocs.org/ https://bitbucket.org/hpk42/py https://pypi.python.org/pypi/py"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="doc"

DEPEND="$(python_abi_depend dev-python/setuptools)
	doc? ( $(python_abi_depend dev-python/sphinx) )
	test? ( $(python_abi_depend ">=dev-python/pytest-2") )"
RDEPEND=""

DOCS="AUTHORS CHANGELOG README.txt"

src_prepare() {
	distutils_src_prepare

	# https://bitbucket.org/hpk42/py/issue/29
	sed -e "s/if sys.version_info < (2,7):/if sys.version_info < (2, 7) or sys.version_info >= (3, 0) and sys.version_info < (3, 2):/" -i py/_code/source.py
}

src_compile() {
	distutils_src_compile

	if use doc; then
		einfo "Generation of documentation"
		pushd doc > /dev/null
		PYTHONPATH=".." emake html
		popd > /dev/null
	fi
}

src_install() {
	distutils_src_install

	if use doc; then
		dohtml -r doc/_build/html/
	fi
}
