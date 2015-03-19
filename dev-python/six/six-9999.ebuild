# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
DISTUTILS_SRC_TEST="py.test"

inherit distutils mercurial

DESCRIPTION="Python 2 and 3 compatibility utilities"
HOMEPAGE="https://bitbucket.org/gutworth/six https://pypi.python.org/pypi/six"
SRC_URI=""
EHG_REPO_URI="https://bitbucket.org/gutworth/six"

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE="doc"

DEPEND="$(python_abi_depend dev-python/setuptools)
	doc? ( $(python_abi_depend dev-python/sphinx) )"
RDEPEND=""

DOCS="CHANGES README"
PYTHON_MODULES="six.py"

src_compile() {
	distutils_src_compile

	if use doc; then
		einfo "Generation of documentation"
		pushd documentation > /dev/null
		emake html
		popd > /dev/null
	fi
}

src_install() {
	distutils_src_install

	if use doc; then
		dohtml -r documentation/_build/html/
	fi
}
