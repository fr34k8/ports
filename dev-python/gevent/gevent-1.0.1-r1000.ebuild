# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_DEPEND="<<[ssl]>>"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.* *-jython *-pypy-*"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*"

inherit distutils

DESCRIPTION="Coroutine-based network library"
HOMEPAGE="http://gevent.org/ https://github.com/surfly/gevent https://pypi.python.org/pypi/gevent"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD MIT"
SLOT="0"
KEYWORDS="*"
IUSE="doc examples"

RDEPEND="dev-libs/libev
	net-dns/c-ares
	$(python_abi_depend dev-python/greenlet)"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)
	doc? ( $(python_abi_depend dev-python/sphinx) )"

PYTHON_CFLAGS=("2.* + -fno-strict-aliasing")

DOCS="AUTHORS changelog.rst"

src_prepare() {
	distutils_src_prepare
	rm -r c-ares libev
}

src_compile() {
	distutils_src_compile

	if use doc; then
		einfo "Generation of documentation"
		pushd doc > /dev/null
		PYTHONPATH="$(ls -d ../build-$(PYTHON -f --ABI)/lib*)" emake html
		popd > /dev/null
	fi
}

src_test() {
	cd greentest

	testing() {
		python_execute PYTHONPATH="$(ls -d ../build-${PYTHON_ABI}/lib.*)" "$(PYTHON)" testrunner.py
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install

	if use doc; then
		dohtml -r doc/_build/html/
	fi

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins -r examples/*
	fi
}
