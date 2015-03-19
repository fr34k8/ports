# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*-jython"

inherit distutils

DESCRIPTION="Various helpers to pass trusted data to untrusted environments and back."
HOMEPAGE="https://pythonhosted.org/itsdangerous/ https://github.com/mitsuhiko/itsdangerous https://pypi.python.org/pypi/itsdangerous"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="doc"

DEPEND="$(python_abi_depend dev-python/setuptools)
	doc? ( $(python_abi_depend dev-python/sphinx) )"
RDEPEND=""

DOCS="CHANGES"
PYTHON_MODULES="itsdangerous.py"

src_prepare() {
	distutils_src_prepare

	preparation() {
		cp tests.py tests.py-${PYTHON_ABI}
		if [[ "$(python_get_version -l --major)" == "3" ]]; then
			2to3-${PYTHON_ABI} -f unicode -nw --no-diffs tests.py-${PYTHON_ABI}
		fi
	}
	python_execute_function preparation
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
	testing() {
		python_execute "$(PYTHON)" tests.py-${PYTHON_ABI}
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install

	if use doc; then
		dohtml -r docs/_build/html/
	fi
}
