# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.5 *-jython"
DISTUTILS_SRC_TEST="py.test"

inherit distutils

DESCRIPTION="Sphinx integration with different issuetrackers"
HOMEPAGE="http://sphinxcontrib-issuetracker.readthedocs.org/ https://github.com/lunaryorn/sphinxcontrib-issuetracker http://pypi.python.org/pypi/sphinxcontrib-issuetracker"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="*"
IUSE="test"

RDEPEND="$(python_abi_depend dev-python/namespaces-sphinxcontrib)
	$(python_abi_depend dev-python/docutils)
	$(python_abi_depend ">=dev-python/requests-1.1")
	$(python_abi_depend ">=dev-python/sphinx-1.1")"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)
	test? ( $(python_abi_depend dev-python/mock) )"

PYTHON_MODULES="${PN/-//}"

src_prepare() {
	distutils_src_prepare

	# Tests from tests/test_stylesheet.py require dev-python/PyQt4[X,webkit] and virtualx.eclass.
	rm -f tests/test_stylesheet.py
}
