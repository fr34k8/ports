# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.*"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="2.7 *-jython"

inherit distutils eutils

DESCRIPTION="OpenID support for servers and consumers."
HOMEPAGE="https://github.com/openid/python-openid https://pypi.python.org/pypi/python-openid"
# Downloaded from https://github.com/openid/python-openid/downloads
SRC_URI="mirror://gentoo/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="examples mysql postgres sqlite"

RDEPEND="mysql? ( $(python_abi_depend -e "*-jython" dev-python/mysql-python) )
	postgres? ( $(python_abi_depend -e "*-jython *-pypy-*" dev-python/psycopg:2) )
	sqlite? ( $(python_abi_depend -e "*-jython" virtual/python-sqlite) )"
DEPEND="${RDEPEND}"

S="${WORKDIR}/openid-python-openid-b666238"

PYTHON_MODULES="openid"

src_prepare() {
	distutils_src_prepare

	# Fix confusion with localhost/127.0.0.1.
	epatch "${FILESDIR}/${PN}-2.0.0-gentoo-test_fetchers.diff"

	# Disable test requiring running db server.
	sed -e "/storetest/d" -i admin/runtests

	# Disable broken tests from from examples/djopenid.
	sed -e "s/django_failures =.*/django_failures = 0/" -i admin/runtests || die "sed admin/runtests failed"
}

src_test() {
	testing() {
		python_execute "$(PYTHON)" admin/runtests
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install

	if use examples; then
		insinto /usr/share/doc/${PF}
		doins -r examples
	fi
}
