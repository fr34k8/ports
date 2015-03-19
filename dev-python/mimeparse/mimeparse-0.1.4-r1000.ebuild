# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.5"

inherit distutils

MY_PN="python-${PN}"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="A module provides basic functions for parsing mime-type names and matching them against a list of media-ranges."
# Original homepages: http://code.google.com/p/mimeparse/ https://pypi.python.org/pypi/mimeparse
HOMEPAGE="https://github.com/dbtsai/python-mimeparse https://pypi.python.org/pypi/python-mimeparse"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND=""
RDEPEND=""

S="${WORKDIR}/${MY_P}"

PYTHON_MODULES="mimeparse.py"

src_test() {
	testing() {
		python_execute PYTHONPATH="build-${PYTHON_ABI}/lib" "$(PYTHON)" mimeparse_test.py
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install

	postinstallational_preparation() {
		touch "${ED}$(python_get_sitedir)/mimeparse-${PV}-py$(python_get_version -l).egg-info"
	}
	python_execute_function -q postinstallational_preparation
}
