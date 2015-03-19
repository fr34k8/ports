# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_DEPEND="<<[{*-cpython}xml]>>"
PYTHON_ABI_TYPE="multiple"
# *-jython: resource module required.
PYTHON_RESTRICTED_ABIS="3.* *-jython"
DISTUTILS_SRC_TEST="setup.py"
PYTHON_NAMESPACES="supervisor"

inherit distutils python-namespaces

DESCRIPTION="A system for controlling process state under UNIX"
HOMEPAGE="http://supervisord.org/ https://github.com/Supervisor/supervisor https://pypi.python.org/pypi/supervisor"
SRC_URI="mirror://pypi/${P:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD GPL-2 HPND repoze ZPL"
SLOT="0"
KEYWORDS="*"
IUSE="doc test"

RDEPEND="$(python_abi_depend dev-python/meld3)
	$(python_abi_depend dev-python/setuptools)"
DEPEND="${RDEPEND}
	doc? ( $(python_abi_depend dev-python/sphinx) )
	test? ( $(python_abi_depend dev-python/mock) )"

S="${WORKDIR}/${P}"

DOCS="CHANGES.txt TODO.txt"

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
	python-namespaces_src_install

	newconfd "${FILESDIR}/supervisord.confd" supervisord
	newinitd "${FILESDIR}/supervisord.initd" supervisord

	delete_tests() {
		rm -r "${ED}$(python_get_sitedir)/supervisor/tests"
	}
	python_execute_function -q delete_tests

	if use doc; then
		dohtml -r docs/.build/html/
	fi
}

pkg_postinst() {
	distutils_pkg_postinst
	python-namespaces_pkg_postinst
}

pkg_postrm() {
	distutils_pkg_postrm
	python-namespaces_pkg_postrm
}
