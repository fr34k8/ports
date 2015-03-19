# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
DISTUTILS_SRC_TEST="setup.py"

inherit distutils

DESCRIPTION="ECDSA cryptographic signature library (pure python)"
HOMEPAGE="https://github.com/warner/python-ecdsa https://pypi.python.org/pypi/ecdsa"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="test"

DEPEND="test? ( dev-libs/openssl:0 )"
RDEPEND=""
