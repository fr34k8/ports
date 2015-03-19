# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="4-python"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.5 3.* *-jython *-pypy-*"
# DISTUTILS_SRC_TEST="nosetests"

inherit distutils

MY_PN="DocumentTemplate"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Document Templating Markup Language (DTML)"
HOMEPAGE="http://pypi.python.org/pypi/DocumentTemplate"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.zip"

LICENSE="ZPL"
SLOT="0"
KEYWORDS="amd64 ~ppc ~ppc64 sparc x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND="$(python_abi_depend dev-python/restrictedpython)
	$(python_abi_depend net-zope/accesscontrol)
	$(python_abi_depend net-zope/acquisition)
	$(python_abi_depend net-zope/extensionclass)
	$(python_abi_depend net-zope/zexceptions)
	$(python_abi_depend net-zope/zope.sequencesort)
	$(python_abi_depend net-zope/zope.structuredtext)"
DEPEND="${RDEPEND}
	app-arch/unzip
	$(python_abi_depend dev-python/setuptools)"

# Tests are broken.
RESTRICT="test"

S="${WORKDIR}/${MY_P}"

DOCS="CHANGES.txt README.txt"
PYTHON_MODULES="DocumentTemplate TreeDisplay"

src_prepare() {
	distutils_src_prepare

	# Disable broken tests.
	rm -f src/DocumentTemplate/sequence/tests/testSequence.py
	sed \
		-e "s/test_fmt_reST_include_directive_raises/_&/" \
		-e "s/test_fmt_reST_raw_directive_disabled/_&/" \
		-e "s/test_fmt_reST_raw_directive_file_option_raises/_&/" \
		-e "s/test_fmt_reST_raw_directive_url_option_raises/_&/" \
		-i src/DocumentTemplate/tests/testDTML.py || die "sed failed"
}

distutils_src_test_pre_hook() {
	local module
	for module in DocumentTemplate; do
		ln -fs "../../$(ls -d build-${PYTHON_ABI}/lib.*)/${module}/c${module}$(python_get_extension_module_suffix)" "src/${module}/c${module}$(python_get_extension_module_suffix)" || die "Symlinking ${module}/c${module}$(python_get_extension_module_suffix) failed with $(python_get_implementation_and_version)"
	done
}

src_install() {
	distutils_src_install
	python_clean_installation_image

	delete_tests() {
		rm -fr "${ED}$(python_get_sitedir)/DocumentTemplate/sequence/tests"
		rm -fr "${ED}$(python_get_sitedir)/DocumentTemplate/tests"
	}
	python_execute_function -q delete_tests
}
