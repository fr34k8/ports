# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.1"
PYTHON_TESTS_RESTRICTED_ABIS="*-jython"
DISTUTILS_SRC_TEST="nosetests"

inherit distutils

DESCRIPTION="Waitress WSGI server"
HOMEPAGE="https://docs.pylonsproject.org/projects/waitress https://github.com/Pylons/waitress https://pypi.python.org/pypi/waitress"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="ZPL"
SLOT="0"
KEYWORDS="*"
IUSE="doc test"

RDEPEND="$(python_abi_depend dev-python/setuptools)"
DEPEND="${RDEPEND}
	doc? ( $(python_abi_depend dev-python/sphinx) )
	test? ( $(python_abi_depend -i "2.6" dev-python/unittest2) )"

DOCS="CHANGES.txt README.rst"

src_prepare() {
	distutils_src_prepare

	# Workaround for Jython.
	sed -e "s/^\([[:space:]]*\)socket_options = \[$/&]\n\1if hasattr(socket, 'SOL_TCP'):\n\1\1socket_options += [/" -i waitress/adjustments.py

	# Fix Sphinx theme.
	sed \
		-e "23,+19d" \
		-e "s/html_theme = 'pylons'/html_theme = 'default'/" \
		-e "/html_theme_options =/d" \
		-i docs/conf.py

	# Fix generation of documentation with Waitress not installed.
	sed -e "s/^version = pkg_resources.get_distribution('waitress').version$/version = '${PV}'/" -i docs/conf.py
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

	delete_tests() {
		rm -r "${ED}$(python_get_sitedir)/waitress/tests"
	}
	python_execute_function -q delete_tests

	if use doc; then
		dohtml -r docs/_build/html/
	fi
}
