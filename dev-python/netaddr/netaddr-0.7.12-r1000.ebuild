# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*-jython"

inherit distutils

DESCRIPTION="Network address representation and manipulation library"
HOMEPAGE="https://github.com/drkjam/netaddr https://pypi.python.org/pypi/netaddr"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="cli"

DEPEND="cli? ( $(python_abi_depend -e "3.1 *-jython" dev-python/ipython) )"
RDEPEND="${DEPEND}"

src_test() {
	testing() {
		python_execute PYTHONPATH="build-${PYTHON_ABI}/lib" "$(PYTHON)" netaddr/tests/__init__.py
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install

	if ! use cli; then
		rm -r "${ED}usr/bin"
	fi
}
