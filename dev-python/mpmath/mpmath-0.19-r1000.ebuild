# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*-jython"
DISTUTILS_SRC_TEST="py.test"

inherit distutils eutils

MY_PN="${PN}-all"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Python library for arbitrary-precision floating-point arithmetic"
HOMEPAGE="http://mpmath.org/ https://github.com/fredrik-johansson/mpmath http://code.google.com/p/mpmath/ https://pypi.python.org/pypi/mpmath"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="doc examples gmp matplotlib"

RDEPEND="gmp? ( $(python_abi_depend -e "*-jython *-pypy" dev-python/gmpy) )
	matplotlib? ( $(python_abi_depend -e "*-jython *-pypy" dev-python/matplotlib) )"
DEPEND="${RDEPEND}
	doc? ( $(python_abi_depend dev-python/sphinx) )"

S="${WORKDIR}/${MY_P}"

DOCS="CHANGES"

src_prepare() {
	distutils_src_prepare

	epatch "${FILESDIR}/${PN}-0.17-avoid_tests_installation.patch"

	# mpmath/conftest.py breaketh test suite.
	rm mpmath/conftest.py

	# Disable test requiring X.
	rm mpmath/tests/test_visualization.py
}

src_compile() {
	distutils_src_compile

	if use doc; then
		einfo "Generation of documentation"
		pushd doc > /dev/null
		python_execute PYTHONPATH="../build-$(PYTHON -f --ABI)/lib" "$(PYTHON -f)" build.py || die "Generation of documentation failed"
		popd > /dev/null
	fi
}

src_install() {
	distutils_src_install

	if use doc; then
		dohtml -r doc/build/
	fi

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins demo/*
	fi
}
