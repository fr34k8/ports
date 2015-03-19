# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
PYTHON_RESTRICTED_ABIS="*-jython"

inherit distutils

MY_PN="PyStemmer"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Snowball stemming algorithms, for information retrieval"
HOMEPAGE="http://snowball.tartarus.org/ https://github.com/snowballstem/pystemmer https://pypi.python.org/pypi/PyStemmer"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="BSD MIT"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="$(python_abi_depend dev-python/cython)"
RDEPEND=""

S="${WORKDIR}/${MY_P}"

DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES="1"
DOCS="ChangeLog"

src_test() {
	testing() {
		PYTHONPATH="$(ls -d build/lib*)" "$(PYTHON)" runtests.py
	}
	python_execute_function -s testing
}
