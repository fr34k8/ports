# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
# *-jython: http://bugs.jython.org/issue1950
# *-jython: http://bugs.jython.org/issue1955
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*-jython"
DISTUTILS_SRC_TEST="setup.py"

inherit distutils eutils

DESCRIPTION="Extensions to the standard Python datetime module"
HOMEPAGE="https://dateutil.readthedocs.org/ https://launchpad.net/dateutil https://github.com/dateutil/dateutil https://pypi.python.org/pypi/python-dateutil"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="$(python_abi_depend dev-python/six)
	sys-libs/timezone-data"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)"

DOCS="NEWS README.rst"
PYTHON_MODULES="dateutil"

src_prepare() {
	distutils_src_prepare

	# Use system zoneinfo and install not dateutil-zoneinfo.tar.gz.
	epatch "${FILESDIR}/${P}-system_zoneinfo.patch"
	sed -e "/package_data=/d" -i setup.py || die "sed failed"
}
