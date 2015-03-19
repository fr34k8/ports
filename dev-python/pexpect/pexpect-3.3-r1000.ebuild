# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="*-jython *-pypy-*"
DISTUTILS_SRC_TEST="py.test"

inherit distutils

DESCRIPTION="Python module for spawning child applications, controlling them and responding to expected patterns in their output"
HOMEPAGE="https://pexpect.readthedocs.org/ https://github.com/pexpect/pexpect https://pypi.python.org/pypi/pexpect"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="ISC"
SLOT="0"
KEYWORDS="*"
IUSE="doc examples"

DEPEND="doc? ( $(python_abi_depend dev-python/sphinx) )"
RDEPEND=""

PYTHON_MODULES="ANSI.py fdpexpect.py FSM.py pexpect pxssh.py screen.py"

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
		doins -r examples/*
	fi
}
