# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.* *-jython"

inherit distutils

MY_PN="MySQL-python"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Python interface to MySQL"
HOMEPAGE="https://github.com/farcepest/MySQLdb1 https://pypi.python.org/pypi/MySQL-python"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.zip"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="doc"

RDEPEND="virtual/mysql"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)
	doc? ( $(python_abi_depend dev-python/sphinx) )"

S="${WORKDIR}/${MY_P}"

PYTHON_CFLAGS=("2.* + -fno-strict-aliasing")

DOCS="HISTORY"
PYTHON_MODULES="MySQLdb _mysql_exceptions.py"

src_compile() {
	distutils_src_compile

	if use doc; then
		einfo "Generation of documentation"
		PYTHONPATH="$(ls -d build-$(PYTHON -f --ABI)/lib*)" "$(PYTHON -f)" setup.py build_sphinx || die "Generation of documentation failed"
	fi
}

src_install() {
	distutils_src_install

	if use doc; then
		dohtml -r build/sphinx/html/
	fi
}
