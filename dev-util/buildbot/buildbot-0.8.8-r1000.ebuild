# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_DEPEND="<<[sqlite]>>"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.* *-jython"
DISTUTILS_SRC_TEST="trial"
DISTUTILS_DISABLE_TEST_DEPENDENCY="1"

inherit distutils systemd user

MY_PV="${PV/_p/p}"
MY_P="${PN}-${MY_PV}"

DESCRIPTION="BuildBot build automation system"
HOMEPAGE="http://trac.buildbot.net/ https://github.com/buildbot/buildbot https://pypi.python.org/pypi/buildbot"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="doc examples irc mail manhole test"

RDEPEND="$(python_abi_depend ">=dev-python/jinja-2.1")
	$(python_abi_depend dev-python/python-dateutil)
	$(python_abi_depend dev-python/sqlalchemy)
	$(python_abi_depend dev-python/sqlalchemy-migrate)
	$(python_abi_depend dev-python/twisted-core)
	$(python_abi_depend dev-python/twisted-web)
	irc? ( $(python_abi_depend dev-python/twisted-words) )
	mail? ( $(python_abi_depend dev-python/twisted-mail) )
	manhole? ( $(python_abi_depend -e "*-pypy-*" dev-python/twisted-conch) )"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)
	doc? ( $(python_abi_depend dev-python/sphinx) )
	test? (
		$(python_abi_depend dev-python/mock)
		$(python_abi_depend dev-python/twisted-mail)
		$(python_abi_depend dev-python/twisted-web)
		$(python_abi_depend dev-python/twisted-words)
	)"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	python_pkg_setup
	enewuser buildbot
}

src_prepare() {
	distutils_src_prepare
	sed \
		-e "s/sqlalchemy >= 0.6, <= 0.7.9/sqlalchemy/" \
		-e "s/sqlalchemy-migrate ==0.6.1, ==0.7.0, ==0.7.1, ==0.7.2/sqlalchemy-migrate/" \
		-e "s/python-dateutil==1.5/python-dateutil/" \
		-i setup.py

	# https://github.com/buildbot/buildbot/issues/1056
	sed -e "/.. option:: --allow-shutdown/a\\\\" -i- docs/manual/installation.rst
	# https://github.com/buildbot/buildbot/issues/1086
	sed -e "s/html_favicon = 'buildbot.ico'/html_favicon = os.path.join('_static', 'buildbot.ico')/" -i docs/conf.py
}

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

	delete_tests() {
		rm -r "${ED}$(python_get_sitedir)/buildbot/test"
	}
	python_execute_function -q delete_tests

	doman docs/buildbot.1

	if use doc; then
		dohtml -r docs/_build/html/
	fi

	if use examples; then
		insinto /usr/share/doc/${PF}
		doins -r contrib docs/examples
	fi

	newconfd "${FILESDIR}/buildmaster.confd" buildmaster
	newinitd "${FILESDIR}/buildmaster.initd" buildmaster
	systemd_dounit "${FILESDIR}/${PN}.service"

	local config_protect_paths=()
	add_config_protect_path() {
		config_protect_paths+=("${EPREFIX}$(python_get_sitedir)/${PN}/status/web")
	}
	python_execute_function -q add_config_protect_path
	newenvd - 85${PN} <<< "CONFIG_PROTECT=\"${config_protect_paths[@]}\""
}

pkg_postinst() {
	distutils_pkg_postinst

	elog "The \"buildbot\" user and the \"buildmaster\" init script has been added"
	elog "to support starting buildbot through Gentoo's init system. To use this,"
	elog "set up your build master following the documentation, make sure the"
	elog "resulting directories are owned by the \"buildbot\" user and point"
	elog "\"${EROOT}etc/conf.d/buildmaster\" at the right location. The scripts can"
	elog "run as a different user if desired. If you need to run more than one"
	elog "build master, just copy the scripts."
	elog
	elog "Upstream recommends the following when upgrading:"
	elog "Each time you install a new version of Buildbot, you should run the"
	elog "\"buildbot upgrade-master\" command on each of your pre-existing build masters."
	elog "This will add files and fix (or at least detect) incompatibilities between"
	elog "your old config and the new code."
}
