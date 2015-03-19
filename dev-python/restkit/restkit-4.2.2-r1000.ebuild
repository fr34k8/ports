# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.5 3.* *-jython"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="2.6"
DISTUTILS_SRC_TEST="nosetests"

inherit distutils

DESCRIPTION="Python REST kit"
HOMEPAGE="https://benoitc.github.io/restkit/ https://github.com/benoitc/restkit https://pypi.python.org/pypi/restkit"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="+cli doc examples"

RDEPEND="$(python_abi_depend ">=dev-python/http-parser-0.8.3")
	$(python_abi_depend ">=dev-python/socketpool-0.5.3")
	$(python_abi_depend dev-python/webob)
	cli? ( $(python_abi_depend dev-python/ipython) )"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)
	doc? (
		$(python_abi_depend dev-python/epydoc)
		$(python_abi_depend dev-python/sphinx)
	)"

src_prepare() {
	distutils_src_prepare

	# Do not install useless files.
	sed -e "/data_files = DATA_FILES,/d" -i setup.py

	if ! use cli; then
		# Do not install script requiring IPython.
		sed -e "s/SCRIPTS = .*/SCRIPTS = []/" -i setup.py
	fi

	# Disable tests requiring network connection.
	sed \
		-e "s/test_007/_&/" \
		-e "s/test_008/_&/" \
		-i tests/004-test-client.py
	rm -f tests/009-test-oauth_filter.py
}

src_compile() {
	distutils_src_compile

	if use doc; then
		einfo "Generation of documentation"
		pushd doc > /dev/null
		PYTHONPATH="../build-$(PYTHON -f --ABI)/lib" emake html
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
