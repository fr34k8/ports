# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
# http://bugs.jython.org/issue1609
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*-jython"

inherit distutils

DESCRIPTION="pytest: simple powerful testing with Python"
HOMEPAGE="http://pytest.org/ https://bitbucket.org/hpk42/pytest https://pypi.python.org/pypi/pytest"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="doc"

RDEPEND="$(python_abi_depend ">=dev-python/py-1.4.25")
	$(python_abi_depend virtual/python-argparse)"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)
	doc? ( $(python_abi_depend dev-python/sphinx) )"

DOCS="CHANGELOG README.rst"
PYTHON_MODULES="pytest.py _pytest"

src_prepare() {
	distutils_src_prepare

	# Disable tests failing with Python 3.1.
	sed -e "s/\([[:space:]]*\)def test_exact_teardown_issue90(/\1@pytest.mark.skipif('sys.version_info[:2] == (3, 1)')\n&/" -i testing/test_runner.py

	# Disable versioning of py.test script to avoid collision with versioning performed by python_merge_intermediate_installation_images().
	sed -e "s/return points/return {'py.test': target}/" -i setup.py || die "sed failed"
}

src_compile() {
	distutils_src_compile

	if use doc; then
		einfo "Generation of documentation"
		pushd doc/en > /dev/null
		PYTHONPATH="../.." emake html
		popd > /dev/null
	fi
}

src_test() {
	testing() {
		python_execute PYTHONPATH="${S}/build-${PYTHON_ABI}/lib" "$(PYTHON)" "build-${PYTHON_ABI}/lib/pytest.py"
	}
	python_execute_function testing

	find -name "__pycache__" -print0 | xargs -0 rm -fr
	find "(" -name "*.py[co]" -o -name "*\$py.class" ")" -delete
}

src_install() {
	distutils_src_install
	python_generate_wrapper_scripts -E -f -q "${ED}usr/bin/py.test"

	if use doc; then
		dohtml -r doc/en/_build/html/
	fi
}
