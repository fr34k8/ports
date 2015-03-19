# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.1 *-jython *-pypy-*"
DISTUTILS_SRC_TEST="nosetests"

inherit distutils

DESCRIPTION="A jquery-like library for python"
HOMEPAGE="https://github.com/gawel/pyquery https://pypi.python.org/pypi/pyquery"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.zip"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="beautifulsoup3 requests restkit test"
REQUIRED_USE="test? ( beautifulsoup3 )"

RDEPEND="$(python_abi_depend dev-python/cssselect)
	$(python_abi_depend ">=dev-python/lxml-2.1[beautifulsoup3?]")
	$(python_abi_depend dev-python/webob)
	requests? ( $(python_abi_depend dev-python/requests) )
	restkit? ( $(python_abi_depend -i "2.*" dev-python/restkit) )"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)
	test? ( $(python_abi_depend dev-python/webtest) )"

DOCS="CHANGES.rst README.rst"

src_prepare() {
	distutils_src_prepare

	# Disable tests failing with libxml2 >=2.9.0.
	sed -e "s/test_replaceWith/_&/" -i tests/test_pyquery.py
}
