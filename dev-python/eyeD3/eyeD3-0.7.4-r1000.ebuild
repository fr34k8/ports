# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.* *-jython *-pypy-*"

inherit distutils

DESCRIPTION="Module for manipulating ID3 (v1 + v2) tags in Python"
HOMEPAGE="http://eyed3.nicfit.net/ https://bitbucket.org/nicfit/eyed3"
SRC_URI="http://eyed3.nicfit.net/releases/${P}.tgz"

LICENSE="GPL-2"
SLOT="0.7"
KEYWORDS="*"
IUSE=""

RDEPEND="$(python_abi_depend -i "2.6" dev-python/ordereddict)
	$(python_abi_depend virtual/python-argparse)
	!<${CATEGORY}/${PN}-0.6.18-r1:0"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/paver)"

DOCS="AUTHORS ChangeLog README.rst"
PYTHON_MODULES="eyed3"

src_prepare() {
	distutils_src_prepare

	cat << EOF > bin/eyeD3
#!/usr/bin/env python

import runpy
runpy.run_module("eyed3.main", run_name="__main__", alter_sys=True)
EOF
}
