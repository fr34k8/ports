# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.*"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*-jython"
DISTUTILS_SRC_TEST="setup.py"

inherit distutils

MY_PN="DecoratorTools"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Class, function, and metaclass decorators"
HOMEPAGE="https://pypi.python.org/pypi/DecoratorTools"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.zip"

LICENSE="|| ( PSF-2 ZPL )"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="$(python_abi_depend dev-python/namespaces-peak[peak,peak.util])"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)"

S="${WORKDIR}/${MY_P}"

PYTHON_MODULES="peak/util/decorators.py"

src_prepare() {
	distutils_src_prepare

	# ABC implementation in Jython is incomplete.
	# http://bugs.jython.org/issue2055
	sed -e "/from abc import ABCMeta as base/i\\    if sys.platform[:4] == 'java': raise ImportError" -i peak/util/decorators.py

	# Disable tests broken with named tuples.
	sed -e "s/additional_tests/_&/" -i test_decorators.py || die "sed failed"
}
