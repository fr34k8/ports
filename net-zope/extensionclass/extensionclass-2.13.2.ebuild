# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="4-python"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.* *-jython"
DISTUTILS_SRC_TEST="nosetests"

inherit distutils

MY_PN="ExtensionClass"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Metaclass for subclassable extension types"
HOMEPAGE="http://pypi.python.org/pypi/ExtensionClass"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.zip"

LICENSE="ZPL"
SLOT="0"
KEYWORDS="amd64 ~ppc ~ppc64 sparc x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux"
IUSE=""

DEPEND="app-arch/unzip
	$(python_abi_depend dev-python/setuptools)"
RDEPEND=""

S="${WORKDIR}/${MY_P}"

PYTHON_CFLAGS=("2.* + -fno-strict-aliasing")

DOCS="CHANGES.txt README.txt"
PYTHON_MODULES="ComputedAttribute ExtensionClass MethodObject"

distutils_src_test_pre_hook() {
	local module
	for module in ComputedAttribute ExtensionClass MethodObject; do
		ln -fs "../../$(ls -d build-${PYTHON_ABI}/lib.*)/${module}/_${module}$(python_get_extension_module_suffix)" "src/${module}/_${module}$(python_get_extension_module_suffix)" || die "Symlinking ${module}/_${module}$(python_get_extension_module_suffix) failed with $(python_get_implementation_and_version)"
	done
}

src_install() {
	distutils_src_install
	python_clean_installation_image
}
