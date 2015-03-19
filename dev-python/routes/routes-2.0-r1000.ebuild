# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.1"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*-jython"
DISTUTILS_SRC_TEST="nosetests"

inherit distutils

MY_PN="Routes"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Routing Recognition and Generation Tools"
HOMEPAGE="https://routes.readthedocs.org/ https://github.com/bbangert/routes https://pypi.python.org/pypi/Routes"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="doc test"

RDEPEND="$(python_abi_depend dev-python/repoze.lru)
	$(python_abi_depend dev-python/setuptools)
	$(python_abi_depend dev-python/webob)"
DEPEND="${RDEPEND}
	doc? ( $(python_abi_depend dev-python/sphinx) )
	test? ( $(python_abi_depend dev-python/webtest) )"

S="${WORKDIR}/${MY_P}"

DOCS="CHANGELOG.rst"

src_prepare() {
	distutils_src_prepare
	sed -e "/py3where = build/d" -i setup.cfg

	preparation() {
		cp -r tests tests-${PYTHON_ABI} || return
		if [[ "$(python_get_version -l --major)" == "3" ]]; then
			2to3-${PYTHON_ABI} -nw --no-diffs tests-${PYTHON_ABI} || return
		fi
	}
	python_execute_function preparation
}

src_compile() {
	distutils_src_compile

	if use doc; then
		einfo "Generation of documentation"
		pushd docs > /dev/null
		PYTHONPATH="../build-$(PYTHON -f --ABI)/lib" emake html
		popd > /dev/null
	fi
}

src_test() {
	python_execute_nosetests -e -P 'build-${PYTHON_ABI}/lib' -- -w 'tests-${PYTHON_ABI}'
}

src_install() {
	distutils_src_install

	if use doc; then
		dohtml -r docs/_build/html/
	fi
}
