# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"

inherit distutils

DESCRIPTION="Recipe for installing Python package distributions as eggs"
HOMEPAGE="https://pypi.python.org/pypi/zc.recipe.egg"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="ZPL"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="$(python_abi_depend net-zope/namespaces-zc[zc,zc.recipe])
	$(python_abi_depend dev-python/setuptools)
	$(python_abi_depend ">=net-zope/zc.buildout-2.0.0")"
RDEPEND="${DEPEND}"

DOCS="CHANGES.txt src/zc/recipe/egg/*.txt"
PYTHON_MODULES="${PN//.//}"
