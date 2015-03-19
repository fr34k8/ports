# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
PYTHON_RESTRICTED_ABIS="3.* *-jython *-pypy"

inherit distutils

DESCRIPTION="Hg-Git plugin for Mercurial"
HOMEPAGE="https://hg-git.github.io/ https://bitbucket.org/durin42/hg-git https://pypi.python.org/pypi/hg-git"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="$(python_abi_depend ">=dev-vcs/mercurial-1.9")
	$(python_abi_depend ">=dev-python/dulwich-0.9.7")
	$(python_abi_depend -i "2.6" dev-python/ordereddict)"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)"

PYTHON_MODULES="hggit"
