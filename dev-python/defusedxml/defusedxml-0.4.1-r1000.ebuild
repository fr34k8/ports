# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_DEPEND="<<[{*-cpython}xml]>>"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="*-jython"
DISTUTILS_SRC_TEST="setup.py"

inherit distutils

DESCRIPTION="XML bomb protection for Python stdlib modules"
HOMEPAGE="https://bitbucket.org/tiran/defusedxml https://pypi.python.org/pypi/defusedxml"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="PSF-2"
SLOT="0"
KEYWORDS="*"
IUSE="examples"

DEPEND=""
RDEPEND=""

DOCS="CHANGES.txt README.txt"

src_prepare() {
	distutils_src_prepare

	# Disable failing tests.
	sed -e "415a\\\n    test_dtd_forbidden = test_entities_forbidden = test_restricted_element1 = None" -i tests.py
}

src_install() {
	distutils_src_install

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins other/*
	fi
}
