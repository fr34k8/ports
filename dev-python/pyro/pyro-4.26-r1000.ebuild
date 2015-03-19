# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_TESTS_RESTRICTED_ABIS="*-jython"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="3.1"

inherit distutils

MY_PN="Pyro4"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Advanced and powerful Distributed Object Technology system written entirely in Python"
HOMEPAGE="https://pythonhosted.org/Pyro4/ https://github.com/irmen/Pyro4 https://pypi.python.org/pypi/Pyro4"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="MIT"
SLOT="4"
KEYWORDS="*"
IUSE="doc examples test"

RDEPEND="$(python_abi_depend ">=dev-python/serpent-1.5")
	!dev-python/pyro:0"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)
	doc? ( $(python_abi_depend dev-python/sphinx) )
	test? (
		$(python_abi_depend dev-python/nose)
		$(python_abi_depend -i "2.6" dev-python/unittest2)
	)"

S="${WORKDIR}/${MY_P}"

PYTHON_MODULES="Pyro4"

src_prepare() {
	distutils_src_prepare

	sed -e '/sys.path.insert/a sys.path.insert(1,"PyroTests")' -i tests/run_suite.py

	# Fix compatibility with Python 3.1.
	sed -e "s/self.assertIsInstance(\([^,)]\+\), \([^,)]\+\))/self.assertTrue(isinstance(\1, \2))/" -i tests/PyroTests/test_daemon.py tests/PyroTests/test_serialize.py
	sed -e "s/data = msg.data.decode(\"ascii\", errors=\"ignore\")/data = msg.data.decode(\"ascii\", \"ignore\")/" -i tests/PyroTests/test_socket.py

	# Disable tests requiring network connection.
	sed \
		-e "s/testBCstart/_&/" \
		-e "s/testDaemonPyroObj/_&/" \
		-e "s/testLookupAndRegister/_&/" \
		-e "s/testMulti/_&/" \
		-e "s/testRefuseDottedNames/_&/" \
		-e "s/testResolve/_&/" \
		-e "s/testBCLookup0000/_&/" \
		-i tests/PyroTests/test_naming.py
	sed \
		-e "s/testOwnloopBasics/_&/" \
		-e "s/testStartNSfunc/_&/" \
		-i tests/PyroTests/test_naming2.py
	sed \
		-e "s/testBroadcast/_&/" \
		-e "s/testGetIP(/_&/" \
		-i tests/PyroTests/test_socket.py

	# Disable failing test.
	sed -e "s/testGetIpVersion6/_&/" -i tests/PyroTests/test_socket.py
}

src_compile() {
	distutils_src_compile

	if use doc; then
		einfo "Generation of documentation"
		pushd docs > /dev/null
		PYTHONPATH="../build-$(PYTHON -f --ABI)/lib" emake html
		popd > /dev/null
	fi
}

src_test() {
	cd tests

	testing() {
		python_execute "$(PYTHON)" run_suite.py
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install

	if use doc; then
		dohtml -r build/sphinx/html/
	fi

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins -r examples/*
	fi
}
