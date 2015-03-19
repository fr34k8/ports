# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="*-jython"
DISTUTILS_SRC_TEST="py.test"

inherit distutils

MY_PN="redis"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Python client for Redis key-value store"
HOMEPAGE="https://github.com/andymccurdy/redis-py https://pypi.python.org/pypi/redis"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="test"

DEPEND="$(python_abi_depend dev-python/setuptools)
	test? ( dev-db/redis )"
RDEPEND=""

S="${WORKDIR}/${MY_P}"

DOCS="README.rst CHANGES"
PYTHON_MODULES="redis"

src_test() {
	local sock="${T}/redis.sock"

	"${EPREFIX}/usr/sbin/redis-server" - <<- EOF
		daemonize yes
		pidfile ${T}/redis.pid
		unixsocket ${sock}
		EOF
	distutils_src_test
	kill "$(<"${T}/redis.pid")"
}
