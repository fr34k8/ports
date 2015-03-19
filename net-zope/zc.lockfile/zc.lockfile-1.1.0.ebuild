# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
# *-jython: fcntl module required.
PYTHON_RESTRICTED_ABIS="2.5 *-jython"
DISTUTILS_SRC_TEST="setup.py"

inherit distutils

DESCRIPTION="Basic inter-process locks"
HOMEPAGE="https://pypi.python.org/pypi/zc.lockfile"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.zip"

LICENSE="ZPL"
SLOT="0"
KEYWORDS="*"
IUSE="test"

RDEPEND="$(python_abi_depend net-zope/namespaces-zc[zc])"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)
	test? ( $(python_abi_depend net-zope/zope.testing) )"

DOCS="CHANGES.txt src/zc/lockfile/README.txt"
PYTHON_MODULES="${PN/.//}"
