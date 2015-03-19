# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*-jython"
DISTUTILS_SRC_TEST="nosetests"

inherit distutils versionator

MY_PN="Sphinx"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Python documentation generator"
HOMEPAGE="http://sphinx-doc.org/ https://github.com/sphinx-doc/sphinx https://pypi.python.org/pypi/Sphinx"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

# Main license: BSD-2
LICENSE="BSD BSD-2 MIT PSF-2 test? ( ElementTree )"
SLOT="0"
KEYWORDS="*"
IUSE="doc latex test"

RDEPEND="$(python_abi_depend dev-python/Babel)
	$(python_abi_depend "=dev-python/alabaster-0.7*")
	$(python_abi_depend dev-python/docutils)
	$(python_abi_depend dev-python/jinja)
	$(python_abi_depend dev-python/pygments)
	$(python_abi_depend dev-python/setuptools)
	$(python_abi_depend dev-python/six)
	$(python_abi_depend dev-python/snowballstemmer)
	$(python_abi_depend "=dev-python/sphinx_rtd_theme-0.1*")
	latex? (
		app-text/dvipng
		dev-texlive/texlive-latexextra
	)"
DEPEND="${RDEPEND}
	test? ( $(python_abi_depend virtual/python-mock) )"

S="${WORKDIR}/${MY_P}"

DOCS="CHANGES"

src_prepare() {
	distutils_src_prepare

	# Support Python 3.1 and 3.2.
	sed -e "s/^if sys.version_info < (2, 6) or (3, 0) <= sys.version_info < (3, 3):$/if sys.version_info < (2, 6):/" -i setup.py
	sed -e "s/(3, 0, 0) <= sys.version_info\[:3\] < (3, 3, 0)/False/" -i sphinx/__init__.py
	sed \
		-e "s/^\([[:space:]]*\)\(from textwrap import indent\)/\1if sys.version_info[:2] >= (3, 3):\n\1    \2/" \
		-e "/# backport from python3/i\\if sys.version_info[:2] < (3, 3):" \
		-i sphinx/util/pycompat.py

	sed -e "/import sys/a\\sys.path.insert(0, '${S}/build-$(PYTHON -f --ABI)/lib')" -i sphinx-build.py
	sed -e "/sys.path.insert(0, os.path.abspath(os.path.join(testroot, os.path.pardir)))/d" -i tests/run.py
}

src_compile() {
	distutils_src_compile

	preparation() {
		cp -r tests tests-${PYTHON_ABI} || return

		if has "$(python_get_version -l)" 3.1; then
			2to3-${PYTHON_ABI} -f callable -nw --no-diffs build-${PYTHON_ABI}/lib tests-${PYTHON_ABI} || return
			sed -e "s/from html import escape as htmlescape[[:space:]]*.*/from cgi import escape as htmlescape/" -i build-${PYTHON_ABI}/lib/sphinx/util/pycompat.py || return
		fi

		if has "$(python_get_version -l)" 3.1 3.2; then
			2to3-${PYTHON_ABI} -f unicode -nw --no-diffs build-${PYTHON_ABI}/lib tests-${PYTHON_ABI} || return
		fi
	}
	python_execute_function -q preparation

	if use doc; then
		einfo "Generation of documentation"
		pushd doc > /dev/null
		emake SPHINXBUILD="$(PYTHON -f) ../sphinx-build.py" html
		popd > /dev/null
	fi
}

src_test() {
	testing() {
		python_execute PYTHONPATH="build-${PYTHON_ABI}/lib" "$(PYTHON)" tests-${PYTHON_ABI}/run.py -w tests-${PYTHON_ABI}
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install
	python_generate_wrapper_scripts -E -f -q "${ED}usr/bin/sphinx-build"

	delete_grammar_pickle() {
		rm -f "${ED}$(python_get_sitedir)/sphinx/pycode/Grammar-py$(python_get_version -l --major)-sphinx$(get_version_component_range 1-2).pickle"
	}
	python_execute_function -q delete_grammar_pickle

	if use doc; then
		dohtml -A txt -r doc/_build/html/
	fi
}

pkg_postinst() {
	distutils_pkg_postinst

	# Generate the Grammar pickle to avoid sandbox violations.
	generate_grammar_pickle() {
		"$(PYTHON)" -c "import sys; sys.path.insert(0, '${EROOT}$(python_get_sitedir -b)'); from sphinx.pycode.pgen2.driver import load_grammar; load_grammar('${EROOT}$(python_get_sitedir -b)/sphinx/pycode/Grammar-py%d.txt' % sys.version_info[0])"
	}
	python_execute_function \
		--action-message 'Generation of Grammar pickle with $(python_get_implementation_and_version)...' \
		--failure-message 'Generation of Grammar pickle with $(python_get_implementation_and_version) failed' \
		generate_grammar_pickle
}

pkg_postrm() {
	distutils_pkg_postrm

	delete_grammar_pickle() {
		rm -f "${EROOT}$(python_get_sitedir -b)/sphinx/pycode/Grammar-py$(python_get_version -l --major)-sphinx$(get_version_component_range 1-2).pickle" || return

		# Delete empty parent directories.
		local dir="${EROOT}$(python_get_sitedir -b)/sphinx/pycode"
		while [[ "${dir}" != "${EROOT%/}" ]]; do
			rmdir "${dir}" 2> /dev/null || break
			dir="${dir%/*}"
		done
	}
	python_execute_function \
		--action-message 'Deletion of Grammar pickle with $(python_get_implementation_and_version)...' \
		--failure-message 'Deletion of Grammar pickle with $(python_get_implementation_and_version) failed' \
		delete_grammar_pickle
}
