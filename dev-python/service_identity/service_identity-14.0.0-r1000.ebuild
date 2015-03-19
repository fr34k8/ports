# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
PYTHON_RESTRICTED_ABIS="3.1 3.2 *-jython"
DISTUTILS_SRC_TEST="py.test"

inherit distutils

DESCRIPTION="Service identity verification for pyOpenSSL."
HOMEPAGE="https://service-identity.readthedocs.org/ https://github.com/pyca/service_identity https://pypi.python.org/pypi/service_identity"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="doc"

RDEPEND="$(python_abi_depend dev-python/characteristic)
	$(python_abi_depend dev-python/pyasn1)
	$(python_abi_depend dev-python/pyasn1-modules)
	$(python_abi_depend dev-python/pyopenssl)"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)
	doc? ( $(python_abi_depend dev-python/sphinx) )"

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

	if use doc; then
		dohtml -r docs/_build/html/
	fi
}
