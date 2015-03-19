# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
PYTHON_RESTRICTED_ABIS="2.6 3.1"
# *-jython: https://github.com/eliben/pyelftools/issues/41
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*-jython"

inherit distutils

DESCRIPTION="Library for analyzing ELF files and DWARF debugging information"
HOMEPAGE="https://github.com/eliben/pyelftools https://pypi.python.org/pypi/pyelftools"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="*"
IUSE="examples"

DEPEND=""
RDEPEND=""

PYTHON_MODULES="elftools"

src_test() {
	testing() {
		local exit_status="0" test
		for test in all_unittests examples_test; do
			python_execute PYTHONPATH="build-${PYTHON_ABI}/lib" "$(PYTHON)" test/run_${test}.py || exit_status="1"
		done

		return "${exit_status}"
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins examples/*.py
	fi
}
