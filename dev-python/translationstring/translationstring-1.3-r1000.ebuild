# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
DISTUTILS_SRC_TEST="setup.py"

inherit distutils

DESCRIPTION="Utility library for i18n relied on by various Repoze and Pyramid packages"
HOMEPAGE="https://docs.pylonsproject.org/projects/translationstring https://github.com/Pylons/translationstring https://pypi.python.org/pypi/translationstring"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="repoze"
SLOT="0"
KEYWORDS="*"
IUSE="doc"

DEPEND="$(python_abi_depend dev-python/setuptools)
	doc? ( $(python_abi_depend dev-python/sphinx) )"
RDEPEND=""

DOCS="README.rst"

src_prepare() {
	distutils_src_prepare

	# Fix Sphinx theme.
	sed \
		-e "s/html_theme = 'pyramid'/html_theme = 'default'/" \
		-e "/html_theme_options =/d" \
		-i docs/conf.py || die "sed failed"
}

src_compile() {
	distutils_src_compile

	if use doc; then
		einfo "Generation of documentation"
		pushd docs > /dev/null
		mkdir _themes
		emake html
		popd > /dev/null
	fi
}

src_install() {
	distutils_src_install

	delete_tests() {
		rm -r "${ED}$(python_get_sitedir)/translationstring/tests"
	}
	python_execute_function -q delete_tests

	if use doc; then
		dohtml -r docs/_build/html/
	fi
}
