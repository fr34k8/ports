# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
# 3.*: https://bitbucket.org/kumar303/fudge/issue/27
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="3.*"
DISTUTILS_SRC_TEST="nosetests"

inherit distutils

DESCRIPTION="Replace real objects with fakes (mocks, stubs, etc) while testing."
HOMEPAGE="http://farmdev.com/projects/fudge/ https://bitbucket.org/kumar303/fudge https://pypi.python.org/pypi/fudge"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="doc"

DEPEND="$(python_abi_depend dev-python/setuptools)
	doc? ( $(python_abi_depend dev-python/sphinx) )"
RDEPEND=""

src_prepare() {
	distutils_src_prepare
	find -name "._*" -delete
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
	python_execute_nosetests -e -P 'build-${PYTHON_ABI}/lib' -- -P 'build-${PYTHON_ABI}/lib'
}

src_install() {
	distutils_src_install

	delete_tests() {
		rm -r "${ED}$(python_get_sitedir)/fudge/tests"
	}
	python_execute_function -q delete_tests

	if use doc; then
		dohtml -r docs/_build/html/
	fi
}
