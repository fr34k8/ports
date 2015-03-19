# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="*-jython"

inherit distutils

MY_PN="Cython"
MY_PV="${PV/_alpha/a}"
MY_PV="${MY_PV/_beta/b}"
MY_PV="${MY_PV/_rc/rc}"
MY_P="${MY_PN}-${MY_PV}"

DESCRIPTION="The Cython compiler for writing C extensions for the Python language"
HOMEPAGE="http://cython.org/ https://github.com/cython/cython https://pypi.python.org/pypi/Cython"
SRC_URI="http://cython.org/release/${MY_P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="doc examples numpy"

DEPEND="$(python_abi_depend dev-python/setuptools)
	numpy? ( $(python_abi_depend -e "*-pypy-*" dev-python/numpy) )"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

PYTHON_CFLAGS=("2.* + -fno-strict-aliasing")

DOCS="CHANGES.rst README.txt ToDo.txt USAGE.txt"
PYTHON_MODULES="Cython cython.py pyximport"

src_test() {
	testing() {
		python_execute "$(PYTHON)" runtests.py -vv --work-dir tests-${PYTHON_ABI}
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install
	python_generate_wrapper_scripts -E -f -q "${ED}usr/bin/cython"

	if use doc; then
		dohtml -A c -r Doc/
	fi

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins -r Demos/*
	fi
}
