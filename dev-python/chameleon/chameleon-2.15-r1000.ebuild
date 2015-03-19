# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="*-jython"
DISTUTILS_SRC_TEST="setup.py"

inherit distutils

MY_PN="Chameleon"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Fast HTML/XML Template Compiler."
HOMEPAGE="http://chameleon.repoze.org/ https://github.com/malthe/chameleon https://pypi.python.org/pypi/Chameleon"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="BSD PSF-2 repoze ZPL"
SLOT="0"
KEYWORDS="*"
IUSE="doc test"

RDEPEND="$(python_abi_depend -i "2.6" dev-python/ordereddict)
	$(python_abi_depend dev-python/setuptools)"
DEPEND="${RDEPEND}
	doc? ( $(python_abi_depend dev-python/sphinx) )
	test? ( $(python_abi_depend -i "2.6" dev-python/unittest2) )"

S="${WORKDIR}/${MY_P}"

DOCS="CHANGES.rst README.rst"

src_compile() {
	distutils_src_compile

	if use doc; then
		einfo "Generation of documentation"
		PYTHONPATH="src" emake html
	fi
}

src_install() {
	distutils_src_install

	delete_tests_and_incompatible_modules() {
		rm -r "${ED}$(python_get_sitedir)/chameleon/tests"

		if [[ "$(python_get_version -l --major)" == "3" ]]; then
			rm "${ED}$(python_get_sitedir)/chameleon/"{benchmark.py,py25.py}
		fi
	}
	python_execute_function -q delete_tests_and_incompatible_modules

	if use doc; then
		dohtml -r _build/html/
	fi
}
