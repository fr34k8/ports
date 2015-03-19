# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"

inherit distutils

DESCRIPTION="A wrapper for the Gnu Privacy Guard (GPG or GnuPG)"
HOMEPAGE="https://pythonhosted.org/python-gnupg/ https://bitbucket.org/vinay.sajip/python-gnupg https://pypi.python.org/pypi/python-gnupg"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="app-crypt/gnupg"
RDEPEND="${DEPEND}"

DOCS=""
PYTHON_MODULES="gnupg.py"
