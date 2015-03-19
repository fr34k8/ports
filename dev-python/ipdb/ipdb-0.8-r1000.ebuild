# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.1 *-jython"
DISTUTILS_SRC_TEST="setup.py"

inherit distutils

DESCRIPTION="IPython-enabled pdb"
HOMEPAGE="https://pypi.python.org/pypi/ipdb"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.zip"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="$(python_abi_depend dev-python/ipython)"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)"

DOCS="HISTORY.txt"

src_prepare() {
	distutils_src_prepare

	# Disable versioning of ipdb script to avoid collision with versioning performed by python_merge_intermediate_installation_images().
	sed -e "s/console_script = 'ipdb%d' % version_info.major/console_script = 'ipdb'/" -i setup.py
}
