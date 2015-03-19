# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.* *-jython *-pypy-*"

inherit distutils

MY_P="Pyrex-${PV}"

DESCRIPTION="A language for writing Python extension modules"
HOMEPAGE="http://www.cosc.canterbury.ac.nz/greg.ewing/python/Pyrex/"
SRC_URI="http://www.cosc.canterbury.ac.nz/greg.ewing/python/Pyrex/${MY_P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="doc examples"

DEPEND=""
RDEPEND=""

S="${WORKDIR}/${MY_P}"

DOCS="CHANGES.txt ToDo.txt USAGE.txt"
PYTHON_MODULES="Pyrex"

src_install() {
	distutils_src_install

	if use doc; then
		dohtml -A c -r Doc/
	fi

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins -r Demos/*
	fi
}
