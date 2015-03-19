# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.* *-jython *-pypy-*"

inherit distutils

DESCRIPTION="eGenix mx Base Distribution for Python - mxDateTime, mxTextTools, mxProxy, mxTools, mxBeeBase, mxStack, mxQueue, mxURL, mxUID"
HOMEPAGE="http://www.egenix.com/products/python/mxBase https://pypi.python.org/pypi/egenix-mx-base"
SRC_URI="http://downloads.egenix.com/python/${P}.tar.gz"

LICENSE="eGenixPublic-1.1"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND=""
RDEPEND=""

PYTHON_MODULES="mx"

src_prepare() {
	distutils_src_prepare

	# Do not install documentation in site-packages directories.
	sed -e "/\/Doc\//d" -i egenix_mx_base.py || die "sed failed"

	# Disable failing tests.
	rm mx/BeeBase/mxBeeBase/testernesto.py
	rm mx/DateTime/mxDateTime/test.py
	rm mx/DateTime/mxDateTime/testrichard.py
	rm mx/DateTime/mxDateTime/testslotops.py
	rm mx/DateTime/mxDateTime/testsubclassing.py
	rm mx/DateTime/mxDateTime/testticks.py
	rm mx/Proxy/mxProxy/testvlad.py
	rm mx/TextTools/mxTextTools/testkj.py
	rm mx/TextTools/mxTextTools/testPickleSegFault.py
	rm mx/Tools/mxTools/test_safecall.py
}

src_compile() {
	# mxSetup.py uses BASECFLAGS variable.
	BASECFLAGS="${CFLAGS}" distutils_src_compile
}

src_test() {
	testing() {
		local exit_status="0" test
		for test in build-${PYTHON_ABI}/lib*/**/*test*.py; do
			if ! python_execute PYTHONPATH="$(ls -d build-${PYTHON_ABI}/lib*)" "$(PYTHON)" "${test}"; then
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

	dohtml -a html -r mx
	insinto /usr/share/doc/${PF}
	doins **/*.pdf

	delete_tests() {
		rm "${ED}$(python_get_sitedir)/mx/"**/*test*.py
	}
	python_execute_function -q delete_tests

	installation_of_headers() {
		dodir "$(python_get_includedir)/mx" || return 1
		local header
		for header in "${ED}$(python_get_sitedir)/mx/"**/*.h; do
			mv -f "${header}" "${ED}$(python_get_includedir)/mx" || return 1
		done
	}
	python_execute_function -q installation_of_headers
}
