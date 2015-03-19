# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.*"
# http://code.google.com/p/python-gflags/issues/detail?id=7
PYTHON_TESTS_RESTRICTED_ABIS="2.7"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*-jython"

inherit distutils

DESCRIPTION="Command line flags module for Python"
HOMEPAGE="http://code.google.com/p/python-gflags/ https://pypi.python.org/pypi/python-gflags"
SRC_URI="http://${PN}.googlecode.com/files/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="$(python_abi_depend dev-python/setuptools)"
RDEPEND=""

PYTHON_MODULES="gflags.py gflags_validators.py"

src_prepare() {
	distutils_src_prepare
	sed -e 's/data_files=\[("bin", \["gflags2man.py"\])\]/scripts=\["gflags2man.py"\]/' -i setup.py
	sed -e "s:tmp_path = '/tmp/flags_unittest':tmp_path = os.path.join(os.environ.get('TMPDIR', '/tmp'), 'flags_unittest'):" -i tests/gflags_unittest.py
}

src_test() {
	testing() {
		local exit_status="0" test
		for test in tests/*.py; do
			if ! python_execute PYTHONPATH="build-${PYTHON_ABI}/lib" "$(PYTHON)" "${test}"; then
				eerror "${test} failed with $(python_get_implementation_and_version)"
				exit_status="1"
			fi
		done

		return "${exit_status}"
	}
	python_execute_function testing
}
