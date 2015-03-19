# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
DISTUTILS_SRC_TEST="py.test"

inherit distutils

DESCRIPTION="Python attributes without boilerplate."
HOMEPAGE="https://characteristic.readthedocs.org/ https://github.com/hynek/characteristic https://pypi.python.org/pypi/characteristic"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="doc"

DEPEND="$(python_abi_depend dev-python/setuptools)
	doc? ( $(python_abi_depend dev-python/sphinx) )"
RDEPEND=""

DOCS="AUTHORS.rst CONTRIBUTING.rst README.rst"
PYTHON_MODULES="characteristic.py"

src_prepare() {
	distutils_src_prepare

	# Install not tests.
	sed -e '/py_modules=/s/, "test_characteristic"//' -i setup.py
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

src_install() {
	distutils_src_install

	if use doc; then
		dohtml -r docs/_build/html/
	fi
}
