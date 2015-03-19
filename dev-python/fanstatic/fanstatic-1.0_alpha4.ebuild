# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.1"
# PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*-jython"
# DISTUTILS_SRC_TEST="py.test"

inherit distutils

MY_P="${PN}-${PV/_alpha/a}"

DESCRIPTION="Flexible static resources for web applications"
HOMEPAGE="http://fanstatic.org/ https://bitbucket.org/fanstatic/fanstatic https://pypi.python.org/pypi/fanstatic"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${MY_P}.zip"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="$(python_abi_depend dev-python/setuptools)
	$(python_abi_depend dev-python/webob)
	$(python_abi_depend dev-python/which)
	$(python_abi_depend virtual/python-argparse)"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

DOCS="CHANGES.txt CREDITS.txt README.txt"

src_prepare() {
	distutils_src_prepare
	sed -e "s/install_requires.append('which==1.1.3.py3')/install_requires.append('which')/" -i setup.py
}
