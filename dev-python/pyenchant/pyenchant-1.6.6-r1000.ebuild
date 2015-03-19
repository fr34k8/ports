# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="*-jython"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*"
DISTUTILS_SRC_TEST="setup.py"

inherit distutils

DESCRIPTION="Python bindings for the Enchant spellchecking system"
HOMEPAGE="https://pythonhosted.org/pyenchant/ https://github.com/rfk/pyenchant https://pypi.python.org/pypi/pyenchant"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND=">=app-text/enchant-${PV%.*}
	$(python_abi_depend dev-python/setuptools)"
RDEPEND="${DEPEND}"

DOCS="README.txt TODO.txt"
PYTHON_MODULES="enchant"

src_test() {
	if [[ -n "$(LC_ALL="en_US.UTF-8" bash -c "" 2>&1)" ]]; then
		ewarn "Disabling tests due to missing en_US.UTF-8 locale"
	else
		distutils_src_test
	fi
}
