# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.* *-jython *-pypy-*"

inherit distutils

MY_P="PyGUI-${PV}"

DESCRIPTION="A cross-platform pythonic GUI API"
HOMEPAGE="http://www.cosc.canterbury.ac.nz/greg.ewing/python_gui/"
SRC_URI="http://www.cosc.canterbury.ac.nz/greg.ewing/python_gui/${MY_P}.tar.gz"

LICENSE="PyGUI"
SLOT="0"
KEYWORDS="*"
IUSE="doc examples"

DEPEND="$(python_abi_depend dev-python/pygtk)"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

PYTHON_MODULES="GUI"

src_install() {
	distutils_src_install

	if use doc; then
		dohtml -r Doc/
	fi

	if use examples; then
		pushd Tests > /dev/null
		insinto /usr/share/doc/${PF}/examples
		doins *.py *.tiff *.jpg
		doins -r ../Demos/*
		popd > /dev/null
	fi
}
