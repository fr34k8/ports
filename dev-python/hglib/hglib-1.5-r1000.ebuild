# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
PYTHON_RESTRICTED_ABIS="3.* *-jython *-pypy"
DISTUTILS_SRC_TEST="nosetests"

inherit distutils

MY_PN="python-${PN}"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Mercurial Python library"
HOMEPAGE="http://mercurial.selenic.com/ https://pypi.python.org/pypi/python-hglib"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="$(python_abi_depend ">=dev-vcs/mercurial-1.9")"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

src_test() {
	testing() {
		python_execute PYTHONPATH="build-${PYTHON_ABI}/lib" "$(PYTHON)" test.py
	}
	python_execute_function testing
}
