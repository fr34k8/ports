# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
# *-jython: http://bugs.jython.org/issue2028
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*-jython"
DISTUTILS_SRC_TEST="setup.py"

inherit distutils

MY_PN="MarkupSafe"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Implements a XML/HTML/XHTML Markup safe string for Python"
HOMEPAGE="https://github.com/mitsuhiko/markupsafe https://pypi.python.org/pypi/MarkupSafe"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="$(python_abi_depend dev-python/setuptools)"
RDEPEND=""

S="${WORKDIR}/${MY_P}"

DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES="1"

src_prepare() {
	distutils_src_prepare

	preparation() {
		if has "$(python_get_version -l)" 3.1 3.2; then
			2to3-${PYTHON_ABI} -f unicode -nw --no-diffs markupsafe
		fi
	}
	python_execute_function -s preparation
}

src_install() {
	distutils_src_install
	python_clean_installation_image

	delete_tests() {
		rm "${ED}$(python_get_sitedir)/markupsafe/tests.py"
	}
	python_execute_function -q delete_tests
}
