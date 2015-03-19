# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*-jython"

inherit distutils

DESCRIPTION="Config file reading, writing and validation."
HOMEPAGE="https://github.com/DiffSK/configobj https://pypi.python.org/pypi/configobj"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="$(python_abi_depend dev-python/six)"
RDEPEND="${DEPEND}"

PYTHON_MODULES="configobj.py validate.py"

src_prepare() {
	distutils_src_prepare

	# Install not _version.py.
	sed -e "/^MODULES =/s/, '_version'//" -i setup.py
	sed -e "s/^from _version import __version__$/__version__ = '${PV}'/" -i configobj.py
}

src_test() {
	testing() {
		python_execute PYTHONPATH="build-${PYTHON_ABI}/lib" "$(PYTHON)" validate.py -v
	}
	python_execute_function testing
}
