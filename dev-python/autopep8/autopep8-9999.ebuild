# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
# http://bugs.jython.org/issue2286
# http://bugs.jython.org/issue2287
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*-jython"

inherit distutils git-2

DESCRIPTION="A tool that automatically formats Python code to conform to the PEP 8 style guide"
HOMEPAGE="https://github.com/hhatto/autopep8 https://pypi.python.org/pypi/autopep8"
SRC_URI=""
EGIT_REPO_URI="https://github.com/hhatto/autopep8"

LICENSE="MIT"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND="$(python_abi_depend ">=dev-python/pep8-1.5.7")
	$(python_abi_depend dev-python/setuptools)
	$(python_abi_depend virtual/python-argparse)"
RDEPEND="${DEPEND}"

DOCS="AUTHORS.rst README.rst"
PYTHON_MODULES="${PN}.py"

src_test() {
	testing() {
		python_execute PYTHONPATH="build-${PYTHON_ABI}/lib" "$(PYTHON)" test/test_autopep8.py
	}
	python_execute_function testing
}
