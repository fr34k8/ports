# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.1"
DISTUTILS_SRC_TEST="nosetests"

inherit distutils

MY_PN="Paver"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Easy build, distribution and deployment scripting"
HOMEPAGE="https://paver.github.io/paver/ https://github.com/paver/paver https://pypi.python.org/pypi/Paver"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="doc test"

DEPEND="$(python_abi_depend dev-python/setuptools)
	test? ( $(python_abi_depend dev-python/mock) )"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

src_install() {
	distutils_src_install

	clean_incompatible_modules() {
		if [[ "$(python_get_version -l --major)" == "2" ]]; then
			echo "raise ImportError" > "${ED}$(python_get_sitedir)/paver/deps/path3.py"
		else
			echo "raise ImportError" > "${ED}$(python_get_sitedir)/paver/deps/path2.py"
		fi
	}
	python_execute_function -q clean_incompatible_modules

	delete_documentation() {
		rm -r "${ED}$(python_get_sitedir)/paver/docs"
	}
	python_execute_function -q delete_documentation

	if use doc; then
		dohtml -r paver/docs/
	fi
}
