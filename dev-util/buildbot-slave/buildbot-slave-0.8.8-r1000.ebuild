# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.* *-jython"
DISTUTILS_SRC_TEST="trial buildslave"
DISTUTILS_DISABLE_TEST_DEPENDENCY="1"

inherit distutils systemd user

MY_PV="${PV/_p/p}"
MY_P="${PN}-${MY_PV}"

DESCRIPTION="BuildBot Slave Daemon"
HOMEPAGE="http://trac.buildbot.net/ https://github.com/buildbot/buildbot https://pypi.python.org/pypi/buildbot-slave"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="test"

RDEPEND="$(python_abi_depend dev-python/setuptools)
	$(python_abi_depend dev-python/twisted-core)
	!!<dev-util/buildbot-0.8.1
	!<dev-util/buildbot-0.8.3"
DEPEND="${RDEPEND}
	test? ( $(python_abi_depend dev-python/mock) )"

S="${WORKDIR}/${MY_P}"

PYTHON_MODULES="buildslave"

pkg_setup() {
	python_pkg_setup
	enewuser buildbot
}

src_install() {
	distutils_src_install

	delete_tests() {
		rm -r "${ED}$(python_get_sitedir)/buildslave/test"
	}
	python_execute_function -q delete_tests

	doman docs/buildslave.1

	newconfd "${FILESDIR}/buildslave.confd" buildslave
	newinitd "${FILESDIR}/buildslave.initd" buildslave
	systemd_dounit "${FILESDIR}/buildslave.service"
}

pkg_postinst() {
	distutils_pkg_postinst

	elog "The \"buildbot\" user and the \"buildslave\" init script has been added"
	elog "to support starting buildslave through Gentoo's init system. To use this,"
	elog "set up your build slave following the documentation, make sure the"
	elog "resulting directories are owned by the \"buildbot\" user and point"
	elog "\"${EROOT}etc/conf.d/buildslave\" at the right location.  The scripts can"
	elog "run as a different user if desired. If you need to run more than one"
	elog "build slave, just copy the scripts."
}
