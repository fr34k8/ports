# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
DISTUTILS_SRC_TEST="setup.py"

inherit distutils

DESCRIPTION="zope.interface extension for defining data schemas"
HOMEPAGE="https://pypi.python.org/pypi/zope.schema"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="ZPL"
SLOT="0"
KEYWORDS="*"
IUSE="doc test"

RDEPEND="$(python_abi_depend net-zope/namespaces-zope[zope])
	$(python_abi_depend -i "2.6" dev-python/ordereddict)
	$(python_abi_depend net-zope/zope.event)
	$(python_abi_depend net-zope/zope.interface)
	$(python_abi_depend net-zope/zope.i18nmessageid)"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)
	doc? ( $(python_abi_depend dev-python/sphinx) )
	test? ( $(python_abi_depend net-zope/zope.testing) )"

DOCS="CHANGES.rst README.rst"
PYTHON_MODULES="${PN/.//}"

src_prepare() {
	distutils_src_prepare
	rm -r docs/_build
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
