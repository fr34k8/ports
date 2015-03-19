# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*-jython"
DISTUTILS_SRC_TEST="setup.py"

inherit distutils

DESCRIPTION="Setuptools revision control system plugin for Git"
HOMEPAGE="https://github.com/wichert/setuptools-git https://pypi.python.org/pypi/setuptools-git"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="$(python_abi_depend dev-python/setuptools)
	dev-vcs/git"
RDEPEND="${DEPEND}"

DOCS="AUTHORS.txt README.rst TODO.txt"
PYTHON_MODULES="setuptools_git"
