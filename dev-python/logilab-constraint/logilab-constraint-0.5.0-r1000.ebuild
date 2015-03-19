# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.*"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*-jython"

inherit distutils

DESCRIPTION="A finite domain constraints solver written in 100% pure Python"
HOMEPAGE="http://www.logilab.org/project/logilab-constraint"
SRC_URI="http://download.logilab.org/pub/constraint/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"
IUSE="examples"

RDEPEND="$(python_abi_depend dev-python/logilab-common)"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)"

DOCS="doc/CONTRIBUTORS"
PYTHON_MODULES="logilab/constraint"

src_test() {
	testing() {
		local tpath="${T}/test-${PYTHON_ABI}"
		local spath="${tpath}${EPREFIX}$(python_get_sitedir)"

		mkdir -p "${spath}/logilab" || return
		cp -r "${EPREFIX}$(python_get_sitedir)/logilab/common" "${spath}/logilab" || return

		python_execute "$(PYTHON)" setup.py build -b "build-${PYTHON_ABI}" install --root="${tpath}" || die "Installation for tests failed with $(python_get_implementation_and_version)"

		# pytest uses tests placed relatively to the current directory.
		pushd "${spath}/logilab/constraint" > /dev/null || return
		python_execute PYTHONPATH="${spath}" pytest -v || return
		popd > /dev/null || return
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install
	dohtml doc/documentation.html

	delete_unneeded_files() {
		# Avoid collisions with dev-python/logilab-common.
		rm -f "${ED}$(python_get_sitedir)/logilab/__init__.py" || return

		# Do not install tests.
		rm -fr "${ED}$(python_get_sitedir)/logilab/constraint/test"
	}
	python_execute_function -q delete_unneeded_files

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins examples/*
	fi
}
