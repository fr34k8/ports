# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"

inherit distutils

DESCRIPTION="A collection of ASN.1-based protocols modules."
HOMEPAGE="http://pyasn1.sourceforge.net/ https://pypi.python.org/pypi/pyasn1-modules"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="$(python_abi_depend ">=dev-python/pyasn1-0.1.1")"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)"

DOCS="CHANGES README"
PYTHON_MODULES="pyasn1_modules"

src_test() {
	testing() {
		local exit_status="0" test
		for test in test/*.sh; do
			if ! python_execute PATH="tools:${PATH}" PYTHONPATH="build-${PYTHON_ABI}/lib" sh "${test}"; then
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

	insinto /usr/share/doc/${PF}/tools
	doins tools/*
}
