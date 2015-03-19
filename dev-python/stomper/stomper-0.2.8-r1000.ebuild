# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.*"
DISTUTILS_SRC_TEST="setup.py"

inherit distutils

DESCRIPTION="Transport neutral client implementation of the STOMP protocol"
HOMEPAGE="https://github.com/oisinmulvihill/stomper https://pypi.python.org/pypi/stomper"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="examples"

DEPEND="$(python_abi_depend dev-python/setuptools)"
RDEPEND=""

src_install() {
	distutils_src_install

	delete_examples_and_tests() {
		rm -r "${ED}$(python_get_sitedir)/${PN}/"{examples,tests}
	}
	python_execute_function -q delete_examples_and_tests

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins lib/stomper/examples/*
	fi
}
