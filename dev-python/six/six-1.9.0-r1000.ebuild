# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
DISTUTILS_SRC_TEST="py.test"

inherit distutils

DESCRIPTION="Python 2 and 3 compatibility utilities"
HOMEPAGE="https://bitbucket.org/gutworth/six https://pypi.python.org/pypi/six"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="doc"

DEPEND="$(python_abi_depend dev-python/setuptools)
	doc? ( $(python_abi_depend dev-python/sphinx) )"
RDEPEND=""

DOCS="CHANGES README"
PYTHON_MODULES="six.py"

src_prepare() {
	distutils_src_prepare

	# Fix compatibility with Python 3.1.
	# https://bitbucket.org/gutworth/six/issue/113
	sed \
		-e '614s/"assertRaisesRegex"/"assertRaisesRegexp" if sys.version_info[1] <= 1 else &/' \
		-e '615s/"assertRegex"/"assertRegexpMatches" if sys.version_info[1] <= 1 else &/' \
		-i six.py
	sed -e "802s/sys.version_info\[:2\] < (2, 7)/& or sys.version_info[:2] in ((3, 0), (3, 1))/" -i test_six.py
}

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
