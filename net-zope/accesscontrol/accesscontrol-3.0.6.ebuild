# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="4-python"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.5 3.* *-jython *-pypy-*"
DISTUTILS_SRC_TEST="nosetests"

inherit distutils

MY_PN="AccessControl"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Security framework for Zope2."
HOMEPAGE="http://pypi.python.org/pypi/AccessControl"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.zip"

LICENSE="ZPL"
SLOT="0"
KEYWORDS="amd64 ~ppc ~ppc64 sparc x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux"
IUSE="test"

RDEPEND="$(python_abi_depend dev-python/restrictedpython)
	$(python_abi_depend net-zope/acquisition)
	$(python_abi_depend net-zope/extensionclass)
	$(python_abi_depend net-zope/persistence)
	$(python_abi_depend net-zope/record)
	$(python_abi_depend net-zope/zexceptions)
	$(python_abi_depend net-zope/zodb)
	$(python_abi_depend net-zope/zope.component)
	$(python_abi_depend net-zope/zope.configuration)
	$(python_abi_depend net-zope/zope.deferredimport)
	$(python_abi_depend net-zope/zope.interface)
	$(python_abi_depend net-zope/zope.publisher)
	$(python_abi_depend net-zope/zope.schema)
	$(python_abi_depend net-zope/zope.security)"
DEPEND="${RDEPEND}
	app-arch/unzip
	$(python_abi_depend dev-python/setuptools)
	test? (
		$(python_abi_depend net-zope/datetime)
		$(python_abi_depend net-zope/transaction)
		$(python_abi_depend net-zope/zope.testing)
	)"

S="${WORKDIR}/${MY_P}"

DOCS="CHANGES.txt README.txt"
PYTHON_MODULES="${MY_PN}"

src_prepare() {
	distutils_src_prepare

	# Disable broken tests.
	rm -f src/AccessControl/tests/testSecurityManager.py
	rm -f src/AccessControl/tests/testZopeSecurityPolicy.py
}

distutils_src_test_pre_hook() {
	local module
	for module in AccessControl; do
		ln -fs "../../$(ls -d build-${PYTHON_ABI}/lib.*)/${module}/c${module}$(python_get_extension_module_suffix)" "src/${module}/c${module}$(python_get_extension_module_suffix)" || die "Symlinking ${module}/c${module}$(python_get_extension_module_suffix) failed with $(python_get_implementation_and_version)"
	done
}

src_install() {
	distutils_src_install
	python_clean_installation_image

	delete_tests() {
		rm -fr "${ED}$(python_get_sitedir)/AccessControl/tests"
	}
	python_execute_function -q delete_tests
}
