# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*-jython"

inherit bash-completion-r1 distutils

MY_PN="Pygments"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Pygments is a syntax highlighting package written in Python."
HOMEPAGE="http://pygments.org/ https://bitbucket.org/birkenfeld/pygments-main https://pypi.python.org/pypi/Pygments"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="doc test"

RDEPEND="$(python_abi_depend dev-python/setuptools)"
DEPEND="${RDEPEND}
	doc? ( $(python_abi_depend dev-python/sphinx) )
	test? (
		$(python_abi_depend dev-python/nose)
		virtual/ttf-fonts
	)"

S="${WORKDIR}/${MY_P}"

DOCS="AUTHORS CHANGES"

src_prepare() {
	distutils_src_prepare

	sed -e "/sys.path.insert(0, os.path.abspath('..'))/d" -i doc/conf.py
	sed -e "/sys.path.insert(0, '..')/d" -i tests/run.py
}

src_compile() {
	distutils_src_compile

	preparation() {
		cp -r tests tests-${PYTHON_ABI} || return

		if has "$(python_get_version -l)" 3.1; then
			sed \
				-e "49s/'missing 1 required positional argument' in err.args\[0\]/'takes at least 2 positional arguments (1 given)' in err.args[0]/" \
				-e "73s/'missing 1 required positional argument' in err.args\[0\]/'takes exactly 3 positional arguments (2 given)' in err.args[0]/" \
				-i build-${PYTHON_ABI}/lib/pygments/__init__.py
		fi

		if has "$(python_get_version -l)" 3.2; then
			sed \
				-e "49s/'missing 1 required positional argument' in err.args\[0\]/'takes at least 2 arguments (1 given)' in err.args[0]/" \
				-e "73s/'missing 1 required positional argument' in err.args\[0\]/'takes exactly 3 arguments (2 given)' in err.args[0]/" \
				-i build-${PYTHON_ABI}/lib/pygments/__init__.py
		fi

		if has "$(python_get_version -l)" 3.1; then
			2to3-${PYTHON_ABI} -f callable -nw --no-diffs build-${PYTHON_ABI}/lib tests-${PYTHON_ABI} || return
		fi

		if has "$(python_get_version -l)" 3.1 3.2; then
			2to3-${PYTHON_ABI} -f unicode -nw --no-diffs build-${PYTHON_ABI}/lib tests-${PYTHON_ABI} || return
			sed -e "s/eval(r\"u/eval(r\"/" -i build-${PYTHON_ABI}/lib/pygments/unistring.py || return
		fi
	}
	python_execute_function -q preparation

	if use doc; then
		einfo "Generation of documentation"
		pushd doc > /dev/null
		PYTHONPATH="../build-$(PYTHON -f --ABI)/lib" emake html SPHINXBUILD="sphinx-build"
		popd > /dev/null
	fi
}

src_test() {
	testing() {
		python_execute PYTHONPATH="build-${PYTHON_ABI}/lib" "$(PYTHON)" tests-${PYTHON_ABI}/run.py
	}
	python_execute_function testing
}

src_install(){
	distutils_src_install
	newbashcomp external/pygments.bashcomp pygmentize

	if use doc; then
		dohtml -r doc/_build/html/
	fi
}
