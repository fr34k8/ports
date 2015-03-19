# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="*-jython *-pypy-*"

inherit distutils

DESCRIPTION="Fast numerical expression evaluator for NumPy"
HOMEPAGE="https://github.com/pydata/numexpr https://pypi.python.org/pypi/numexpr"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="mkl"

RDEPEND="$(python_abi_depend dev-python/numpy)
	mkl? ( sci-libs/mkl )"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)"

DOCS="ANNOUNCE.rst AUTHORS.txt README.rst RELEASE_NOTES.rst"

src_prepare() {
	if use mkl; then
		if ! use amd64 && ! use x86; then
			die "Unsupported architecture"
		fi

		echo "[mkl]" >> site.cfg
		echo "include_dirs = ${MKLROOT}/include" >> site.cfg
		if has_version "<sci-libs/mkl-11"; then
			if use amd64; then
				echo "library_dirs = ${MKLROOT}/lib/em64t" >> site.cfg
			elif use x86; then
				echo "library_dirs = ${MKLROOT}/lib/32" >> site.cfg
			fi
		else
			if use amd64; then
				echo "library_dirs = ${MKLROOT}/lib/intel64" >> site.cfg
			elif use x86; then
				echo "library_dirs = ${MKLROOT}/lib/ia32" >> site.cfg
			fi
		fi
		if use amd64; then
			echo "mkl_libs = mkl_solver_lp64, mkl_intel_lp64, mkl_intel_thread, mkl_core, iomp5" >> site.cfg
		elif use x86; then
			echo "mkl_libs = mkl_solver, mkl_intel, mkl_intel_thread, mkl_core, iomp5" >> site.cfg
		fi
	fi
}

src_test() {
	testing() {
		pushd "$(ls -d build-${PYTHON_ABI}/lib*)" > /dev/null
		python_execute "$(PYTHON)" -m numexpr.tests.test_numexpr || return
		popd > /dev/null
	}
	python_execute_function testing
}
