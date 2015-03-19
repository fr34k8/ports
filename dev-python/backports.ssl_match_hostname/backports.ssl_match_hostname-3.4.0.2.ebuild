# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.[2-9]"

inherit distutils

DESCRIPTION="The ssl.match_hostname() function from Python 3.4"
HOMEPAGE="https://bitbucket.org/brandon/backports.ssl_match_hostname https://pypi.python.org/pypi/backports.ssl_match_hostname"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="PSF-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="$(python_abi_depend dev-python/namespaces-backports)"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)"

PYTHON_MODULES="${PN/.//}"

src_prepare() {
	distutils_src_prepare
	mv src/backports/ssl_match_hostname/*.txt .

	# Fix usage of namespace.
	sed -e "/^[[:space:]]*packages =/a\\    namespace_packages = ['backports']," -i setup.py
	echo "__import__('pkg_resources').declare_namespace(__name__)" > src/backports/__init__.py
}
