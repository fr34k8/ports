# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="4-python"
PYTHON_MULTIPLE_ABIS="1"

inherit distutils

DESCRIPTION="Sphinx extension: auto-generates API docs from Zope interfaces"
HOMEPAGE="http://pypi.python.org/pypi/repoze.sphinx.autointerface"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="repoze"
SLOT="0"
KEYWORDS="amd64 ~ppc ~ppc64 sparc x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND="$(python_abi_depend dev-python/namespaces-repoze[repoze,repoze.sphinx])
	$(python_abi_depend dev-python/sphinx)
	$(python_abi_depend net-zope/zope.interface)"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)"

DOCS="CHANGES.txt README.txt TODO.txt"
PYTHON_MODULES="${PN//.//}.py"
