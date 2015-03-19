# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
DISTUTILS_SRC_TEST="setup.py"

inherit distutils

DESCRIPTION="Exclude specific directories from nosetests runs."
HOMEPAGE="https://pypi.python.org/pypi/nose-exclude"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="$(python_abi_depend dev-python/nose)"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)"

PYTHON_MODULES="nose_exclude.py"
