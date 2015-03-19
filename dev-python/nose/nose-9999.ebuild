# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
# 2.6: https://github.com/nose-devs/nose/issues/781
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="2.6 *-jython"

inherit distutils git-2

DESCRIPTION="nose extends unittest to make testing easier"
HOMEPAGE="https://nose.readthedocs.org/ https://github.com/nose-devs/nose https://pypi.python.org/pypi/nose"
SRC_URI=""
EGIT_REPO_URI="https://github.com/nose-devs/nose"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS=""
IUSE="doc examples test"

RDEPEND="$(python_abi_depend dev-python/coverage)
	$(python_abi_depend dev-python/setuptools)"
DEPEND="${RDEPEND}
	doc? ( $(python_abi_depend dev-python/sphinx) )
	test? ( $(python_abi_depend -e "3.* *-jython" dev-python/twisted-core) )"

DOCS="AUTHORS"

src_prepare() {
	distutils_src_prepare

	sed \
		-e "/^sys.path.insert(.*)$/d" \
		-e "/^sys.path.insert(/,/)$/d" \
		-i doc/conf.py

	# Disable versioning of nosetests script to avoid collision with versioning performed by python_merge_intermediate_installation_images().
	sed -e "/'nosetests%s = nose:run_exit' % py_vers_tag,/d" -i setup.py || die "sed failed"

	# Disable tests requiring network connection.
	sed \
		-e "s/test_resolve/_&/g" \
		-e "s/test_raises_bad_return/_&/g" \
		-e "s/test_raises_twisted_error/_&/g" \
		-i unit_tests/test_twisted.py || die "sed failed"
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

src_test() {
	# Some test failures result in leaving of some files causing test failures with other Python ABIs.
	python_copy_sources

	testing() {
		if [[ "$(python_get_version -l --major)" == "3" ]]; then
			python_execute "$(PYTHON)" setup.py build_tests || return
		fi

		python_execute "$(PYTHON)" setup.py egg_info || return
		python_execute PATH="$(pwd)/bin:${PATH}" PYTHONPATH="build-${PYTHON_ABI}/lib" "$(PYTHON)" selftest.py -v
	}
	python_execute_function -s testing
}

src_install() {
	distutils_src_install --install-data "${EPREFIX}/usr/share"

	python_generate_wrapper_scripts -E -f -q "${ED}usr/bin/nosetests"

	if use doc; then
		dohtml -r doc/.build/html/
	fi

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins -r examples/*
	fi
}
