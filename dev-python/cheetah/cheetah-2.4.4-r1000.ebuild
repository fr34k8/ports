# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.5 3.*"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*-jython"

inherit distutils

MY_PN="Cheetah"
MY_P="${MY_PN}-${PV/_}"

DESCRIPTION="Python-powered template engine and code generator."
HOMEPAGE="http://www.cheetahtemplate.org/ http://rtyler.github.io/cheetah/ https://pypi.python.org/pypi/Cheetah"
SRC_URI="mirror://pypi/${MY_P:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="MIT"
IUSE=""
KEYWORDS="*"
SLOT="0"

RDEPEND="$(python_abi_depend dev-python/markdown)"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)"

S="${WORKDIR}/${MY_P}"

DOCS="CHANGES README.markdown TODO"
PYTHON_MODULES="Cheetah"

src_prepare() {
	distutils_src_prepare

	# Disable broken tests.
	sed \
		-e "/Unicode/d" \
		-e "s/if not sys.platform.startswith('java'):/if False:/" \
		-e "/results =/a\\    sys.exit(not results.wasSuccessful())" \
		-i cheetah/Tests/Test.py || die "sed failed"
}

src_test() {
	testing() {
		python_execute PYTHONPATH="$([[ -d build-${PYTHON_ABI}/lib ]] && echo build-${PYTHON_ABI}/lib || ls -d build-${PYTHON_ABI}/lib*)" "$(PYTHON)" cheetah/Tests/Test.py
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install

	delete_tests() {
		rm -fr "${ED}$(python_get_sitedir)/Cheetah/Tests"
	}
	python_execute_function -q delete_tests
}
