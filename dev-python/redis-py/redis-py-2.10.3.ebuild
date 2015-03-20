# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-python/redis-py/redis-py-2.10.3.ebuild,v 1.4 2014/12/05 10:15:22 ago Exp $

EAPI=5
PYTHON_COMPAT=( python{2_7,3_3,3_4} pypy )

inherit distutils-r1

MY_PN="redis"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Python client for Redis key-value store"
HOMEPAGE="http://github.com/andymccurdy/redis-py"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 ~hppa x86 ~amd64-linux ~x86-linux"
IUSE="test"

RDEPEND=""
DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]
	test? ( dev-db/redis
		>=dev-python/pytest-2.5.0[${PYTHON_USEDEP}] )"

S="${WORKDIR}/${MY_P}"

python_prepare_all() {
	# Make sure that tests will be used from BUILD_DIR rather than cwd.
	mv tests tests-hidden || die

	# Correct local import patch syntax
	sed -e 's:from .conftest:from conftest:' \
		-i tests-hidden/{test_connection_pool.py,test_commands.py,test_encoding.py,test_pubsub.py} \
		|| die

	distutils-r1_python_prepare_all
}

python_compile() {
	distutils-r1_python_compile

	if use test; then
		cp -r tests-hidden "${BUILD_DIR}"/tests || die
	fi
}

src_test() {
	# testsuite fails miserably under multiprocessing
	local DISTUTILS_NO_PARALLEL_BUILD=1
	distutils-r1_src_test
}

python_test() {

	local sock="${T}/redis.sock"

	"${EPREFIX}/usr/sbin/redis-server" - <<- EOF
		daemonize yes
		pidfile ${T}/redis.pid
		unixsocket ${sock}
		EOF

	PYTHONPATH="${S}:${S}/tests-hidden"
	esetup.py test
	kill "$(<"${T}/redis.pid")"
}