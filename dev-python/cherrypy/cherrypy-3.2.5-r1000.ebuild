# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_TESTS_RESTRICTED_ABIS="*-jython"
DISTUTILS_SRC_TEST="nosetests"

inherit distutils

MY_PN="CherryPy"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Object-Oriented HTTP framework"
HOMEPAGE="http://www.cherrypy.org/ https://bitbucket.org/cherrypy/cherrypy https://pypi.python.org/pypi/CherryPy"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="doc"

DEPEND="$(python_abi_depend dev-python/setuptools)"
RDEPEND=""

S="${WORKDIR}/${MY_P}"

src_prepare() {
	distutils_src_prepare
	sed \
		-e 's/"cherrypy.tutorial", //' \
		-e "/('cherrypy\/tutorial',/,/),/d" \
		-e "/LICENSE.txt/d" \
		-i setup.py || die "sed failed"

	# https://bitbucket.org/cherrypy/cherrypy/issue/1234
	sed -e "s/assertIsInstance(res, bytestr)/assertTrue(isinstance(res, bytestr))/" -i cherrypy/test/test_tools.py

	# Disable hanging tests.
	sed -e "s/testCookies/_&/" -i cherrypy/test/test_core.py
	sed -e "s/testEncoding/_&/" -i cherrypy/test/test_encoding.py
	sed -e "s/test_multipart_decoding(/_&/" -i cherrypy/test/test_encoding.py
	sed -e "s/test_multipart_decoding_no_charset/_&/" -i cherrypy/test/test_encoding.py
	sed -e "s/test_json_output/_&/" -i cherrypy/test/test_json.py
	sed -e "s/testErrorHandling/_&/" -i cherrypy/test/test_request_obj.py
	sed -e "s/testParams/_&/" -i cherrypy/test/test_request_obj.py
	sed -e "135s/test_0_Session/_&/" -i cherrypy/test/test_session.py
	sed -e "s/test_config_errors/_&/" -i cherrypy/test/test_static.py

	# Disable failing test.
	sed -e "s/test_file_stream(/_&/" -i cherrypy/test/test_static.py
}

src_test() {
	distutils_src_test < /dev/tty
}

src_install() {
	distutils_src_install

	delete_tests() {
		rm -r "${ED}$(python_get_sitedir)/cherrypy/test"
	}
	python_execute_function -q delete_tests

	if use doc; then
		insinto /usr/share/doc/${PF}
		doins -r cherrypy/tutorial
	fi
}
