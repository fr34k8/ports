# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="4-python"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.* *-jython"

inherit distutils

DESCRIPTION="Convenience uid/gid helper function used in Zope2."
HOMEPAGE="http://pypi.python.org/pypi/initgroups"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.zip"

LICENSE="ZPL"
SLOT="0"
KEYWORDS="amd64 ~ppc ~ppc64 sparc x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux"
IUSE=""

DEPEND="app-arch/unzip
	$(python_abi_depend dev-python/setuptools)"
RDEPEND=""

DOCS="CHANGES.txt README.txt"

src_install() {
	distutils_src_install
	python_clean_installation_image
}
