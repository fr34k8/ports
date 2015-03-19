# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"

inherit distutils

DESCRIPTION="Python package for providing Mozilla's CA Bundle."
HOMEPAGE="http://python-requests.org/ https://pypi.python.org/pypi/certifi"
SRC_URI="mirror://pypi/${P:0:1}/${PN}/${P}.tar.gz"

LICENSE="ISC"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="$(python_abi_depend dev-python/setuptools)"
RDEPEND="app-misc/ca-certificates"

src_install() {
	distutils_src_install

	create_cacert.pem_symlink() {
		# Overwrite bundled certificates with a symlink.
		dosym "${EPREFIX}/etc/ssl/certs/ca-certificates.crt" "$(python_get_sitedir -b)/certifi/cacert.pem"
	}
	python_execute_function -q create_cacert.pem_symlink
}
