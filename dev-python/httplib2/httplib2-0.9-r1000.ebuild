# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_DEPEND="<<[{*-cpython}ssl]>>"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.1"
# https://github.com/jcgregorio/httplib2/issues/270
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*"

inherit distutils

DESCRIPTION="A comprehensive HTTP client library."
HOMEPAGE="https://github.com/jcgregorio/httplib2 https://pypi.python.org/pypi/httplib2"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="$(python_abi_depend dev-python/setuptools)"
RDEPEND=""

src_test() {
	testing() {
		pushd "python$(python_get_version -l --major)" > /dev/null
		python_execute "$(PYTHON)" httplib2test.py -v || return
		popd > /dev/null
	}
	python_execute_function testing
}
