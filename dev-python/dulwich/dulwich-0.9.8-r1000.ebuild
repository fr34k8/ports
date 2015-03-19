# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
PYTHON_RESTRICTED_ABIS="3.* *-jython"
DISTUTILS_SRC_TEST="setup.py"

inherit distutils

DESCRIPTION="Python Git Library"
HOMEPAGE="http://www.samba.org/~jelmer/dulwich/ https://github.com/jelmer/dulwich https://pypi.python.org/pypi/dulwich"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="doc examples ssh test"

RDEPEND="ssh? ( $(python_abi_depend -e "*-pypy" dev-python/paramiko) )"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)
	doc? ( $(python_abi_depend dev-python/sphinx) )
	test? (
		$(python_abi_depend dev-python/mock)
		$(python_abi_depend -e "*-pypy" dev-python/gevent)
		$(python_abi_depend -i "2.6" dev-python/unittest2)
	)"

src_prepare() {
	distutils_src_prepare

	# Disable optional dependencies of tests.
	sed "/tests_require=tests_require/d" -i setup.py
}

src_compile() {
	distutils_src_compile

	if use doc; then
		einfo "Generation of documentation"
		pushd docs > /dev/null
		emake html
		popd > /dev/null
	fi
}

src_install() {
	distutils_src_install
	python_clean_installation_image

	delete_tests() {
		rm -r "${ED}$(python_get_sitedir)/dulwich/"{contrib/test_*.py,tests}
	}
	python_execute_function -q delete_tests

	if use doc; then
		dohtml -r docs/build/html/
	fi

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins examples/*
	fi
}
