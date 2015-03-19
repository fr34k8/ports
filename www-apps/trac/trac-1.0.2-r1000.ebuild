# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_DEPEND="<<[sqlite?]>>"
PYTHON_ABI_TYPE="multiple"
PYTHON_RESTRICTED_ABIS="3.* *-jython"

inherit distutils user webapp

MY_PV="${PV/_beta/b}"
MY_P="Trac-${MY_PV}"

DESCRIPTION="Integrated SCM, wiki, issue tracker and project environment"
HOMEPAGE="http://trac.edgewall.com/ https://pypi.python.org/pypi/Trac"
SRC_URI="http://ftp.edgewall.com/pub/trac/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="cgi fastcgi i18n mysql postgres +sqlite subversion"
REQUIRED_USE="|| ( mysql postgres sqlite )"

DEPEND="$(python_abi_depend dev-python/docutils)
	$(python_abi_depend ">=dev-python/genshi-0.6")
	$(python_abi_depend dev-python/pygments)
	$(python_abi_depend dev-python/pytz)
	$(python_abi_depend dev-python/setuptools)
	cgi? ( virtual/httpd-cgi )
	fastcgi? ( virtual/httpd-fastcgi )
	i18n? ( $(python_abi_depend dev-python/Babel) )
	mysql? ( $(python_abi_depend dev-python/mysql-python) )
	postgres? ( $(python_abi_depend -e "*-pypy" dev-python/psycopg:2) )
	subversion? ( $(python_abi_depend -e "*-pypy" dev-vcs/subversion[python]) )"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

WEBAPP_MANUAL_SLOT="yes"

pkg_setup() {
	python_pkg_setup
	webapp_pkg_setup

	enewgroup tracd
	enewuser tracd -1 -1 -1 tracd
}

src_prepare() {
	distutils_src_prepare
}

src_test() {
	testing() {
		python_execute PYTHONPATH="." "$(PYTHON)" trac/test.py
	}
	python_execute_function testing

	if use i18n; then
		make check
	fi
}

# the default src_compile just calls setup.py build
# currently, this switches i18n catalog compilation based on presence of Babel

src_install() {
	webapp_src_preinst
	distutils_src_install

	# project environments might go in here
	keepdir /var/lib/trac

	# Use this as the egg-cache for tracd
	dodir /var/lib/trac/egg-cache
	keepdir /var/lib/trac/egg-cache
	fowners tracd:tracd /var/lib/trac/egg-cache

	# documentation
	dodoc -r contrib

	# tracd init script
	newconfd "${FILESDIR}"/tracd.confd tracd
	newinitd "${FILESDIR}"/tracd.initd tracd

	if use cgi; then
		cp contrib/cgi-bin/trac.cgi "${ED}${MY_CGIBINDIR}" || die
	fi
	if use fastcgi; then
		cp contrib/cgi-bin/trac.fcgi "${ED}${MY_CGIBINDIR}" || die
	fi

	for lang in en; do
		webapp_postinst_txt ${lang} "${FILESDIR}"/postinst-${lang}.txt
		webapp_postupgrade_txt ${lang} "${FILESDIR}"/postupgrade-${lang}.txt
	done

	webapp_src_install
}

pkg_postinst() {
	distutils_pkg_postinst
	webapp_pkg_postinst
}
