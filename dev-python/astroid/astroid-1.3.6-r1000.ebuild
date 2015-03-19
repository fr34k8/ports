# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
PYTHON_RESTRICTED_ABIS="2.6 3.1 3.2"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*-jython"

inherit distutils

DESCRIPTION="A abstract syntax tree for Python with inference support."
HOMEPAGE="http://astroid.org/ https://bitbucket.org/logilab/astroid https://pypi.python.org/pypi/astroid"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"
IUSE="test"

# Version specified in astroid/__pkginfo__.py.
RDEPEND="$(python_abi_depend ">=dev-python/logilab-common-0.60.0")
	$(python_abi_depend dev-python/setuptools)
	$(python_abi_depend dev-python/six)"
DEPEND="${RDEPEND}
	test? (
		$(python_abi_depend -e "3.* *-jython *-pypy" dev-python/egenix-mx-base)
		$(python_abi_depend dev-python/pylint)
	)"

src_test() {
	testing() {
		local tpath="${T}/test-${PYTHON_ABI}"
		local spath="${tpath}$(python_get_sitedir)"

		python_execute "$(PYTHON)" setup.py build -b "build-${PYTHON_ABI}" install --root="${tpath}" || die "Installation for tests failed with $(python_get_implementation_and_version)"

		# pytest uses tests placed relatively to the current directory.
		pushd "${spath}/astroid" > /dev/null || return
		python_execute PYTHONPATH="${spath}" pytest -v || return
		popd > /dev/null || return
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install

	delete_tests() {
		rm -r "${ED}$(python_get_sitedir)/astroid/tests"
	}
	python_execute_function -q delete_tests
}
