# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="3.1"
DISTUTILS_SRC_TEST="setup.py"

inherit distutils

DESCRIPTION="A library for converting a token stream into a data structure for use in web form posts"
HOMEPAGE="https://docs.pylonsproject.org/projects/peppercorn https://github.com/Pylons/peppercorn https://pypi.python.org/pypi/peppercorn"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="repoze"
SLOT="0"
KEYWORDS="*"
IUSE="doc"

DEPEND="$(python_abi_depend dev-python/setuptools)
	doc? ( $(python_abi_depend dev-python/sphinx) )"
RDEPEND=""

DOCS="CHANGES.txt README.txt"

src_prepare() {
	distutils_src_prepare

	# Fix Sphinx theme.
	sed -e "/# Add and use Pylons theme/,+36d" -i docs/conf.py || die "sed failed"
}

src_compile() {
	distutils_src_compile

	if use doc; then
		einfo "Generation of documentation"
		pushd docs > /dev/null
		PYTHONPATH=".." emake html
		popd > /dev/null
	fi
}

src_install() {
	distutils_src_install

	delete_tests() {
		rm "${ED}$(python_get_sitedir)/peppercorn/tests.py"
	}
	python_execute_function -q delete_tests

	if use doc; then
		dohtml -r docs/_build/html/
	fi
}
