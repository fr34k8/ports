# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*"
DISTUTILS_SRC_TEST="py.test"

inherit distutils eutils

DESCRIPTION="A collection of tools for internationalizing Python applications"
HOMEPAGE="http://babel.pocoo.org/ https://github.com/mitsuhiko/babel https://pypi.python.org/pypi/Babel"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="doc"

RDEPEND="$(python_abi_depend dev-python/pytz)
	$(python_abi_depend dev-python/setuptools)"
DEPEND="${RDEPEND}
	doc? ( $(python_abi_depend dev-python/sphinx) )"

DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES="1"
PYTHON_MODULES="babel"

src_prepare() {
	epatch "${FILESDIR}/${P}-tests.patch"

	# https://github.com/mitsuhiko/babel/issues/46
	sed -e "s/utf_8/utf-8/" -i babel/util.py

	# Fix compatibility with Python 3.1.
	sed -e "201s/if PY2:/if __import__('sys').version_info < (3, 2):/" -i babel/messages/mofile.py

	distutils_src_prepare

	preparation() {
		if has "$(python_get_version -l)" 3.1 3.2; then
			2to3-${PYTHON_ABI} -f unicode -nw --no-diffs babel tests
		fi
	}
	python_execute_function -s preparation
}

src_compile() {
	distutils_src_compile

	if use doc; then
		einfo "Generation of documentation"
		pushd docs > /dev/null
		emake html
		popd > /dev/null
	fi
}

src_install() {
	distutils_src_install

	if use doc; then
		dohtml -r docs/_build/html/
	fi
}
