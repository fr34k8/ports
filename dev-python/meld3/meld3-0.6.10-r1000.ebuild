# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_DEPEND="<<[{*-cpython}xml]>>"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.*"

inherit distutils

DESCRIPTION="meld3 is an HTML/XML templating engine."
HOMEPAGE="https://github.com/Supervisor/meld3 https://pypi.python.org/pypi/meld3"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="ZPL"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND=""
RDEPEND=""

DOCS="CHANGES.txt README.txt TODO.txt"

set_environmental_variables() {
	if [[ "$(python_get_implementation)" != "Jython" ]]; then
		export USE_MELD3_EXTENSION_MODULES="1"
	else
		unset USE_MELD3_EXTENSION_MODULES
	fi
}

distutils_src_compile_pre_hook() {
	set_environmental_variables
}

distutils_src_install_pre_hook() {
	set_environmental_variables
}

src_test() {
	testing() {
		python_execute PYTHONPATH="$(ls -d build-${PYTHON_ABI}/lib*)" "$(PYTHON)" "$(ls -d build-${PYTHON_ABI}/lib*)/meld3/test_meld3.py"
	}
	python_execute_function testing
}
