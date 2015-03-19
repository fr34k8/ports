# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*-jython"
DISTUTILS_SRC_TEST="setup.py"

inherit distutils

MY_PN="Jinja2"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="A small but fast and easy to use stand-alone template engine written in pure python."
HOMEPAGE="http://jinja.pocoo.org/ https://github.com/mitsuhiko/jinja2 https://pypi.python.org/pypi/Jinja2"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="doc examples i18n vim-syntax"

RDEPEND="$(python_abi_depend dev-python/markupsafe)
	$(python_abi_depend dev-python/setuptools)
	i18n? ( $(python_abi_depend -e "3.1 3.2" dev-python/Babel) )"
DEPEND="${RDEPEND}
	doc? ( $(python_abi_depend dev-python/sphinx) )"

S="${WORKDIR}/${MY_P}"

DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES="1"
DOCS="CHANGES"
PYTHON_MODULES="jinja2"

src_prepare() {
	# https://github.com/mitsuhiko/jinja2/commit/da94a8b504d981cb5f877219811d169823a2095e
	# https://github.com/mitsuhiko/jinja2/commit/b89d1a8fe3fcbd73a8f4cebd4358eadebc2d8a9d
	sed -e "/from jinja2.utils import next/d" -i docs/jinjaext.py

	distutils_src_prepare

	preparation() {
		if has "$(python_get_version -l)" 3.1; then
			sed -e "s/callable(\(.*\))/isinstance(\1, __import__('collections').Callable)/" -i jinja2/nodes.py
			sed -e "s/test_callable = callable/test_callable = lambda x: isinstance(x, __import__('collections').Callable)/" -i jinja2/tests.py
		fi

		if has "$(python_get_version -l)" 3.1 3.2; then
			2to3-${PYTHON_ABI} -f unicode -nw --no-diffs jinja2
		fi
	}
	python_execute_function -s preparation
}

src_compile(){
	distutils_src_compile

	if use doc; then
		einfo "Generation of documentation"
		generate_documentation() {
			pushd docs > /dev/null
			PYTHONPATH="../build/lib" emake html
			popd > /dev/null
		}
		python_execute_function -f -q -s generate_documentation
	fi
}

src_install(){
	distutils_src_install

	delete_tests() {
		rm -r "${ED}$(python_get_sitedir)/jinja2/testsuite"
	}
	python_execute_function -q delete_tests

	if use doc; then
		install_documentation() {
			dohtml -r docs/_build/html/
		}
		python_execute_function -f -q -s install_documentation
	fi

	if use examples; then
		insinto /usr/share/doc/${PF}
		doins -r examples
	fi

	if use vim-syntax; then
		insinto /usr/share/vim/vimfiles/syntax
		doins ext/Vim/*
	fi
}
