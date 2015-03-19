# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="4-python"
PYTHON_DEPEND="<<[tk,xml]>>"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.* *-jython *-pypy-*"

inherit distutils

DESCRIPTION="Natural Language Toolkit"
HOMEPAGE="http://www.nltk.org/ https://github.com/nltk/nltk http://pypi.python.org/pypi/nltk"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="amd64 x86 ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~x86-solaris"
IUSE=""

RDEPEND="$(python_abi_depend dev-python/numpy)
	$(python_abi_depend dev-python/pyyaml)"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)"
