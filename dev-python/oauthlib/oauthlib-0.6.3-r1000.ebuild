# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*-jython *-pypy-*"
DISTUTILS_SRC_TEST="nosetests"

inherit distutils

DESCRIPTION="A generic, spec-compliant, thorough implementation of the OAuth request-signing logic"
HOMEPAGE="https://github.com/idan/oauthlib https://pypi.python.org/pypi/oauthlib"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="test"

RDEPEND="$(python_abi_depend -e "${PYTHON_TESTS_FAILURES_TOLERANT_ABIS}" dev-python/pycrypto)
	$(python_abi_depend dev-python/pyjwt)"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)
	test? (
		$(python_abi_depend dev-python/mock)
		$(python_abi_depend -i "2.6" dev-python/unittest2)
	)"

src_prepare() {
	distutils_src_prepare

	# Fix compatibility with Python 3.1.
	sed -e "s/callable(\([^)]\+\))/(hasattr(\1, '__call__') if __import__('sys').version_info\[:2\] == (3, 1) else &)/" -i oauthlib/oauth2/rfc6749/tokens.py
}
