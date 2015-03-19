# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
PYTHON_RESTRICTED_ABIS="*-jython *-pypy"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="3.*"
DISTUTILS_SRC_TEST="nosetests"

inherit distutils

DESCRIPTION="Highly concurrent networking library"
HOMEPAGE="http://eventlet.net/ https://github.com/eventlet/eventlet https://bitbucket.org/eventlet/eventlet https://pypi.python.org/pypi/eventlet"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="doc examples"

RDEPEND="$(python_abi_depend dev-python/greenlet)
	$(python_abi_depend dev-python/pyopenssl)"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)
	doc? ( $(python_abi_depend dev-python/sphinx) )"

src_prepare() {
	distutils_src_prepare

	# Disable failing tests.
	# https://bitbucket.org/eventlet/eventlet/issue/159
	# https://github.com/eventlet/eventlet/issues/191
	sed -e "s/test_incomplete_headers_13/_&/" -i tests/websocket_new_test.py
	sed \
		-e "s/test_incomplete_headers_75/_&/" \
		-e "s/test_incomplete_headers_76/_&/" \
		-e "s/test_incorrect_headers/_&/" \
		-i tests/websocket_test.py
	sed -e "s/test_server_connection_timeout_exception/_&/" -i tests/wsgi_test.py

	# Disable installation of tests.
	# https://github.com/eventlet/eventlet/issues/190
	sed -e "/find_packages/s/'tests'/&, 'tests.*'/" -i setup.py
}

src_compile() {
	distutils_src_compile

	if use doc; then
		einfo "Generation of documentation"
		pushd doc > /dev/null
		emake html
		popd > /dev/null
	fi
}

src_install() {
	distutils_src_install

	if use doc; then
		dohtml -r doc/_build/html/
	fi

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins examples/*
	fi
}
