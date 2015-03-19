# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.5"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*-jython"
DISTUTILS_SRC_TEST="setup.py"

inherit distutils

DESCRIPTION="Generic Transparent Proxies"
HOMEPAGE="https://pypi.python.org/pypi/zope.proxy"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.zip"

LICENSE="ZPL"
SLOT="0"
KEYWORDS="*"
IUSE="doc"

RDEPEND="$(python_abi_depend net-zope/namespaces-zope[zope])
	$(python_abi_depend net-zope/zope.interface)"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)
	doc? (
		$(python_abi_depend dev-python/repoze.sphinx.autointerface)
		$(python_abi_depend dev-python/sphinx)
	)"

PYTHON_CFLAGS=("2.* + -fno-strict-aliasing")

DISTUTILS_GLOBAL_OPTIONS=("*-jython --without-Cwrapper")
DOCS="CHANGES.rst README.rst"
PYTHON_MODULES="${PN/.//}"

src_compile() {
	distutils_src_compile

	if use doc; then
		einfo "Generation of documentation"
		pushd docs > /dev/null
		PYTHONPATH="$(ls -d ../build-$(PYTHON -f --ABI)/lib*)" emake html
		popd > /dev/null
	fi
}

src_install() {
	distutils_src_install
	python_clean_installation_image

	if use doc; then
		dohtml -r docs/_build/html/
	fi
}
