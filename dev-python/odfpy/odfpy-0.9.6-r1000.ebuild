# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.* *-jython"

inherit distutils eutils

DESCRIPTION="Python API and tools to manipulate OpenDocument files"
HOMEPAGE="https://joinup.ec.europa.eu/software/odfpy/home http://pypi.python.org/pypi/odfpy"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="Apache-2.0 GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND=""
RDEPEND=""

PYTHON_MODULES="odf"

src_prepare() {
	distutils_src_prepare
	epatch "${FILESDIR}/${PN}-0.9.4-tests.patch"
}

src_test() {
	cd tests

	testing() {
		local exit_status="0" test
		for test in test*.py; do
			if ! python_execute PYTHONPATH="../build-${PYTHON_ABI}/lib" "$(PYTHON)" "${test}"; then
				eerror "${test} failed with $(python_get_implementation_and_version)"
				exit_status="1"
			fi
		done

		return "${exit_status}"
	}
	python_execute_function testing
}
