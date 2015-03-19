# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="*-jython"

inherit distutils

DESCRIPTION="A full-screen, console-based Python debugger"
HOMEPAGE="https://pypi.python.org/pypi/pudb"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="$(python_abi_depend dev-python/pygments)
	$(python_abi_depend dev-python/setuptools)
	$(python_abi_depend dev-python/urwid)"
RDEPEND="${DEPEND}"

src_prepare() {
	distutils_src_prepare

	# Disable versioning of pudb script to avoid collision with versioning performed by python_merge_intermediate_installation_images().
	sed -e "s/PY_VERSION = str(py_version_major)/PY_VERSION = ''/" -i setup.py
}
