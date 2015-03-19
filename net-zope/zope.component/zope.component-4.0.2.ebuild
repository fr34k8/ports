# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.5"
PYTHON_TESTS_RESTRICTED_ABIS="3.* *-jython *-pypy-*"
DISTUTILS_SRC_TEST="setup.py"

inherit distutils

DESCRIPTION="Zope Component Architecture"
HOMEPAGE="http://pypi.python.org/pypi/zope.component"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="ZPL"
SLOT="0"
KEYWORDS="*"
IUSE="doc test"

RDEPEND="$(python_abi_depend net-zope/namespaces-zope[zope])
	$(python_abi_depend -e "${PYTHON_TESTS_RESTRICTED_ABIS}" net-zope/zodb)
	$(python_abi_depend net-zope/zope.configuration)
	$(python_abi_depend net-zope/zope.event)
	$(python_abi_depend net-zope/zope.hookable)
	$(python_abi_depend net-zope/zope.i18nmessageid)
	$(python_abi_depend net-zope/zope.interface)
	$(python_abi_depend net-zope/zope.proxy)
	$(python_abi_depend net-zope/zope.schema)"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)
	doc? (
		$(python_abi_depend dev-python/repoze.sphinx.autointerface)
		$(python_abi_depend dev-python/sphinx)
	)
	test? ( $(python_abi_depend -e "${PYTHON_TESTS_RESTRICTED_ABIS}" net-zope/zope.testing) )"
PDEPEND="$(python_abi_depend -e "${PYTHON_TESTS_RESTRICTED_ABIS}" net-zope/zope.security)"

DOCS="CHANGES.txt README.txt"
PYTHON_MODULES="${PN/.//}"

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
