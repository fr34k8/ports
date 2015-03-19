# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.5 3.* *-jython"
DISTUTILS_SRC_TEST="trial"
DISTUTILS_DISABLE_TEST_DEPENDENCY="1"

inherit distutils

DESCRIPTION="RPC protocol for Twisted"
HOMEPAGE="http://foolscap.lothar.com/trac https://pypi.python.org/pypi/foolscap"
SRC_URI="http://${PN}.lothar.com/releases/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="doc ssl"

RDEPEND="$(python_abi_depend dev-python/twisted-core)
	$(python_abi_depend dev-python/twisted-web)
	ssl? ( $(python_abi_depend dev-python/pyopenssl) )"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)
	doc? ( dev-python/twisted-lore )"

src_compile() {
	distutils_src_compile

	if use doc; then
		einfo "Generation of documentation"
		emake docs
	fi
}

src_test() {
	LC_ALL="C" distutils_src_test
}

src_install() {
	distutils_src_install

	delete_tests() {
		rm -fr "${ED}$(python_get_sitedir)/foolscap/test"
	}
	python_execute_function -q delete_tests

	if use doc; then
		dodoc doc/*.txt
		dohtml -a css,html,py -r doc/
	fi
}
