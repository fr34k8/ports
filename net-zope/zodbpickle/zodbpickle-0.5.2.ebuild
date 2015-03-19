# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.1 *-jython *-pypy-*"
DISTUTILS_SRC_TEST="setup.py"

inherit distutils

DESCRIPTION="Fork of Python pickle module"
HOMEPAGE="https://pypi.python.org/pypi/zodbpickle"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="PSF-2 ZPL"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="$(python_abi_depend dev-python/setuptools)"
RDEPEND=""

PYTHON_CFLAGS=("2.* + -fno-strict-aliasing")

DOCS="CHANGES.rst README.rst"

src_install() {
	distutils_src_install
	python_clean_installation_image

	delete_tests_and_incompatible_modules() {
		rm -fr "${ED}$(python_get_sitedir)/zodbpickle/tests"

		if [[ "$(python_get_version -l --major)" == "2" ]]; then
			rm -f "${ED}$(python_get_sitedir)/zodbpickle/"{pickle_3.py,pickletools_3.py}
		else
			rm -f "${ED}$(python_get_sitedir)/zodbpickle/"{pickle_2.py,pickletools_2.py}
		fi
	}
	python_execute_function -q delete_tests_and_incompatible_modules
}
