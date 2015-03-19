# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.5"

inherit distutils

DESCRIPTION="Recipe for installing Python scripts"
HOMEPAGE="https://pypi.python.org/pypi/z3c.recipe.scripts"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="ZPL"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="$(python_abi_depend net-zope/namespaces-z3c[z3c,z3c.recipe])
	$(python_abi_depend dev-python/setuptools)
	$(python_abi_depend ">=net-zope/zc.buildout-1.5.0")
	$(python_abi_depend ">=net-zope/zc.recipe.egg-1.3.0")"
RDEPEND="${DEPEND}"

DOCS="CHANGES.txt src/z3c/recipe/scripts/*.txt"
PYTHON_MODULES="${PN//.//}"
