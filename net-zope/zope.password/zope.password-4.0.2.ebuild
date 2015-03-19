# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.5 3.1 3.2 *-jython *-pypy-*"
DISTUTILS_SRC_TEST="setup.py"

inherit distutils

DESCRIPTION="Password encoding and checking utilities"
HOMEPAGE="https://pypi.python.org/pypi/zope.password"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.zip"

LICENSE="ZPL"
SLOT="0"
KEYWORDS="*"
IUSE="test"

RDEPEND="$(python_abi_depend net-zope/namespaces-zope[zope])
	$(python_abi_depend net-zope/zope.component)
	$(python_abi_depend net-zope/zope.configuration)
	$(python_abi_depend net-zope/zope.interface)
	$(python_abi_depend net-zope/zope.schema)"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)
	test? (
		$(python_abi_depend net-zope/zope.testing)
		$(python_abi_depend net-zope/zope.testrunner)
	)"

DOCS="CHANGES.txt README.txt"
PYTHON_MODULES="${PN/.//}"

src_test() {
	testing() {
		# setup.py excessively passes arguments to zope.testrunner.
		python_execute PYTHONPATH="build-${PYTHON_ABI}/lib" "$(PYTHON)" setup.py test
	}
	python_execute_function testing
}
