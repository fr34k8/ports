# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="2.6 *-jython"

inherit distutils

DESCRIPTION="DNS toolkit for Python"
HOMEPAGE="http://www.dnspython.org/ https://github.com/rthalley/dnspython https://pypi.python.org/pypi/dnspython https://pypi.python.org/pypi/dnspython3"
SRC_URI="http://www.dnspython.org/kits/${PV}/${P}.tar.gz http://www.dnspython.org/kits3/${PV}/${PN}3-${PV}.tar.gz"

LICENSE="ISC"
SLOT="0"
KEYWORDS="*"
IUSE="examples pycrypto"

DEPEND="pycrypto? ( $(python_abi_depend -e "*-jython *-pypy-*" dev-python/pycrypto) )"
RDEPEND="${DEPEND}"

DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES="1"
DOCS="ChangeLog README"
PYTHON_MODULES="dns"

src_prepare() {
	preparation() {
		if [[ "$(python_get_version -l --major)" == "2" ]]; then
			cp -r "${WORKDIR}/${P}" "${S}-${PYTHON_ABI}"
		else
			cp -r "${WORKDIR}/${PN}3-${PV}" "${S}-${PYTHON_ABI}"
		fi
	}
	python_execute_function preparation
}

src_test() {
	testing() {
		cd tests

		local exit_status="0" test
		for test in test_*.py; do
			if ! python_execute PYTHONPATH="../build/lib" "$(PYTHON)" "${test}"; then
				eerror "${test} failed with $(python_get_implementation_and_version)"
				exit_status="1"
			fi
		done

		return "${exit_status}"
	}
	python_execute_function -s testing
}

src_install() {
	distutils_src_install

	if use examples; then
		install_examples() {
			insinto /usr/share/doc/${PF}/examples/python$(python_get_version -l --major)
			doins examples/*
		}
		python_execute_function -q -s install_examples
	fi
}
