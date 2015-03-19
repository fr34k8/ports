# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
PYTHON_RESTRICTED_ABIS="*-jython *-pypy"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="3.1"

inherit distutils

MY_PN="${PN}2"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Python bindings for GMP, MPC, MPFR and MPIR libraries"
HOMEPAGE="http://code.google.com/p/gmpy/ https://pypi.python.org/pypi/gmpy2"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.zip"

LICENSE="LGPL-2.1"
SLOT="2"
KEYWORDS="*"
IUSE="doc mpir"

RDEPEND=">=dev-libs/mpc-1.0:0=
	>=dev-libs/mpfr-3.1:0=
	!mpir? ( dev-libs/gmp:0= )
	mpir? ( sci-libs/mpir:0= )"
DEPEND="${RDEPEND}
	doc? ( $(python_abi_depend dev-python/sphinx) )"

S="${WORKDIR}/${MY_P}"

PYTHON_CFLAGS=("2.* + -fno-strict-aliasing")

pkg_setup() {
	python_pkg_setup
	DISTUTILS_GLOBAL_OPTIONS=("* $(usex mpir --mpir --gmp)")
}

src_prepare() {
	distutils_src_prepare
	sed -e "s/if sys.version.startswith('3.1'):/if False:/" -i test/runtests.py
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

src_test() {
	testing() {
		local exit_status="0" test
		for test in test/runtests.py test$(python_get_version -l --major)/gmpy_test.py; do
			if ! python_execute PYTHONPATH="$(ls -d build-${PYTHON_ABI}/lib.*)" "$(PYTHON)" "${test}"; then
				eerror "${test} failed with $(python_get_implementation_and_version)"
				exit_status="1"
			fi
		done

		return "${exit_status}"
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install

	if use doc; then
		dohtml -r docs/_build/html/
	fi
}
