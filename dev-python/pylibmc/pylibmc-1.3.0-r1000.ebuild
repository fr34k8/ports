# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.* *-jython"
DISTUTILS_SRC_TEST="nosetests"

inherit distutils

DESCRIPTION="Libmemcached wrapper written as a Python extension"
HOMEPAGE="http://sendapatch.se/projects/pylibmc/ https://pypi.python.org/pypi/pylibmc"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND=">=dev-libs/libmemcached-0.32"
RDEPEND="${DEPEND}"

src_prepare() {
	distutils_src_prepare
	sed -e "/with-info=1/d" -i setup.cfg
}

src_test() {
	memcached -d -l localhost -p 11219 -P "${T}/memcached.pid" -u nobody
	MEMCACHED_PORT="11219" distutils_src_test
	kill "$(<"${T}/memcached.pid")"
}
