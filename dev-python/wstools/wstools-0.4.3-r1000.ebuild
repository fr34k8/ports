# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_DEPEND="<<[{*-cpython}xml]>>"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.*"

inherit distutils

DESCRIPTION="WSDL parsing services package for Web Services for Python"
HOMEPAGE="http://pywebsvcs.sourceforge.net/ https://pypi.python.org/pypi/wstools"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="$(python_abi_depend dev-python/setuptools)"
RDEPEND=""

DOCS="CHANGES.txt README.txt"

src_prepare() {
	distutils_src_prepare
	sed -e "/install_requires=\['docutils'\],/d" -i setup.py
}
