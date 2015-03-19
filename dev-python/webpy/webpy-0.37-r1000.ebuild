# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="4-python"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.*"

inherit distutils

MY_PN="web.py"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="A small and simple web framework for Python"
HOMEPAGE="http://www.webpy.org http://pypi.python.org/pypi/web.py"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="amd64 ~hppa x86 ~amd64-linux ~x86-linux"
IUSE=""

DEPEND=""
RDEPEND=""

S="${WORKDIR}/${MY_P}"

PYTHON_MODULES="web"

src_test() {
	testing() {
		local exit_status="0" test
		for test in db http net template utils; do
			if ! python_execute "$(PYTHON)" web/${test}.py; then
				eerror "${test} failed with $(python_get_implementation_and_version)"
				exit_status="1"
			fi
		done

		return "${exit_status}"
	}
	python_execute_function testing
}
