# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.5 3.*"
# DISTUTILS_SRC_TEST="nosetests"

inherit distutils

MY_PN="PasteScript"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="A pluggable command-line frontend, including commands to setup package file layouts"
HOMEPAGE="http://pythonpaste.org/script/ https://pypi.python.org/pypi/PasteScript"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="doc"

RDEPEND="$(python_abi_depend dev-python/namespaces-paste)
	$(python_abi_depend dev-python/cheetah)
	$(python_abi_depend ">=dev-python/paste-1.3")
	$(python_abi_depend dev-python/pastedeploy)
	$(python_abi_depend dev-python/setuptools)"
DEPEND="${RDEPEND}
	doc? (
		$(python_abi_depend dev-python/pygments)
		$(python_abi_depend dev-python/sphinx)
	)"

# Tests are broken.
RESTRICT="test"

S="${WORKDIR}/${MY_P}"

PYTHON_MODULES="paste/script"

src_compile() {
	distutils_src_compile

	if use doc; then
		einfo "Generation of documentation"
		PYTHONPATH="." "$(PYTHON -f)" setup.py build_sphinx || die "Generation of documentation failed"
	fi
}

src_install() {
	distutils_src_install

	delete_tests() {
		rm -fr "${ED}$(python_get_sitedir)/tests"
	}
	python_execute_function -q delete_tests

	if use doc; then
		dohtml -r build/sphinx/html/
	fi
}
