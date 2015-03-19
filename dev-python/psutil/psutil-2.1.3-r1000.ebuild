# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.1 *-jython"
# https://github.com/giampaolo/psutil/issues/538
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*"

inherit distutils

DESCRIPTION="psutil is a cross-platform library for retrieving information on running processes and system utilization (CPU, memory, disks, network) in Python."
HOMEPAGE="https://pythonhosted.org/psutil/ https://github.com/giampaolo/psutil https://pypi.python.org/pypi/psutil"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="doc test"

DEPEND="$(python_abi_depend dev-python/setuptools)
	doc? ( $(python_abi_depend dev-python/sphinx) )
	test? ( $(python_abi_depend -i "2.6" dev-python/unittest2) )"
RDEPEND=""

DOCS="CREDITS HISTORY.rst README.rst"

src_compile() {
	distutils_src_compile

	if use doc; then
		einfo "Generation of documentation"
		pushd docs > /dev/null
		emake html
		popd > /dev/null
	fi
}

src_test() {
	testing() {
		python_execute PYTHONPATH="$(ls -d build-${PYTHON_ABI}/lib*)" "$(PYTHON)" test/test_memory_leaks.py || return
		python_execute PYTHONPATH="$(ls -d build-${PYTHON_ABI}/lib*)" "$(PYTHON)" test/test_psutil.py || return
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install

	if use doc; then
		dohtml -r docs/_build/html/
	fi
}
