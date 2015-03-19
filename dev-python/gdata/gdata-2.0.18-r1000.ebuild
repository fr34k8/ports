# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_DEPEND="<<[{*-cpython}ssl,{*-cpython}xml]>>"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.*"

inherit distutils

DESCRIPTION="Python client library for Google data APIs"
HOMEPAGE="http://code.google.com/p/gdata-python-client/ https://pypi.python.org/pypi/gdata"
SRC_URI="http://gdata-python-client.googlecode.com/files/${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="examples"

DEPEND=""
RDEPEND=""

DOCS="RELEASE_NOTES.txt"
PYTHON_MODULES="atom gdata"

src_test() {
	testing() {
		python_execute PYTHONPATH="build-${PYTHON_ABI}/lib" "$(PYTHON)" tests/run_data_tests.py -v || return

		# run_service_tests.py requires interaction (and a valid Google account), so skip it.
		# python_execute PYTHONPATH="build-${PYTHON_ABI}/lib" "$(PYTHON)" tests/run_service_tests.py -v || return
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins -r samples/*
	fi
}
