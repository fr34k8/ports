# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="4-python"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.* *-jython"
DISTUTILS_SRC_TEST="nosetests"

inherit distutils

MY_PN="RestrictedPython"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="RestrictedPython provides a restricted execution environment for Python, e.g. for running untrusted code."
HOMEPAGE="http://pypi.python.org/pypi/RestrictedPython"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.zip"

LICENSE="ZPL"
SLOT="0"
KEYWORDS="amd64 ~ppc ~ppc64 sparc x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux"
IUSE=""

DEPEND="app-arch/unzip
	$(python_abi_depend dev-python/setuptools)"
RDEPEND=""

S="${WORKDIR}/${MY_P}"

DOCS="CHANGES.txt src/RestrictedPython/README.txt"
PYTHON_MODULES="${MY_PN}"

pkg_postinst() {
	python_mod_optimize -x /tests/ ${MY_PN}
}
