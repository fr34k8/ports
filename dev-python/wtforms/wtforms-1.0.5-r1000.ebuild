# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.5"
# http://bugs.jython.org/issue1964
PYTHON_TESTS_RESTRICTED_ABIS="*-jython"

inherit distutils eutils

MY_PN="WTForms"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="A flexible forms validation and rendering library for python web development."
HOMEPAGE="http://wtforms.simplecodes.com/ https://github.com/wtforms/wtforms https://pypi.python.org/pypi/WTForms"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.zip"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="doc"

S="${WORKDIR}/${MY_P}"

DEPEND="$(python_abi_depend dev-python/setuptools)
	doc? ( $(python_abi_depend dev-python/sphinx) )"
RDEPEND=""

DOCS="AUTHORS.txt CHANGES.txt README.txt"

src_prepare() {
	distutils_src_prepare

	# Fix compatibility with Python 3.1.
	cat << EOF >> wtforms/compat.py
try:
    callable = callable
except NameError:
    def callable(x):
        import collections
        return isinstance(x, collections.Callable)
EOF
	sed -e "/from wtforms import validators/a\\from wtforms.compat import callable" -i wtforms/ext/sqlalchemy/orm.py
}

src_compile() {
	distutils_src_compile

	if use doc; then
		einfo "Generation of documentation"
		pushd docs > /dev/null
		PYTHONPATH="../build-$(PYTHON -f --ABI)/lib" emake html
		popd > /dev/null
	fi
}

src_test() {
	testing() {
		python_execute PYTHONPATH="build-${PYTHON_ABI}/lib" "$(PYTHON)" tests/runtests.py
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install

	if use doc; then
		dohtml -r docs/_build/html/
	fi
}
