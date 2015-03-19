# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.5 3.* *-jython"
DISTUTILS_SRC_TEST="nosetests"

inherit distutils

DESCRIPTION="Alternative Python bindings for Subversion"
HOMEPAGE="http://www.samba.org/~jelmer/subvertpy/ https://pypi.python.org/pypi/subvertpy"
SRC_URI="http://www.samba.org/~jelmer/${PN}/${P}.tar.gz"

LICENSE="|| ( LGPL-2.1 LGPL-3 )"
SLOT="0"
KEYWORDS="*"
IUSE="test"

RDEPEND=">=dev-vcs/subversion-1.4"
DEPEND="${RDEPEND}
	test? (
		|| (
			$(python_abi_depend -i "2.6" dev-python/unittest2)
			$(python_abi_depend -i "2.6" dev-python/testtools)
		)
	)"

S="${WORKDIR}"

PYTHON_CFLAGS=("2.* + -fno-strict-aliasing")

DOCS="AUTHORS NEWS README"

distutils_src_test_pre_hook() {
	local module
	for module in _ra client repos wc; do
		ln -fs "../$(ls -d build-${PYTHON_ABI}/lib.*)/subvertpy/${module}$(python_get_extension_module_suffix)" "subvertpy/${module}$(python_get_extension_module_suffix)" || die "Symlinking subvertpy/${module}$(python_get_extension_module_suffix) failed with $(python_get_implementation_and_version)"
	done
}

src_install() {
	distutils_src_install

	delete_tests() {
		rm -fr "${ED}$(python_get_sitedir)/subvertpy/tests/"test_*.py
	}
	python_execute_function -q delete_tests
}
