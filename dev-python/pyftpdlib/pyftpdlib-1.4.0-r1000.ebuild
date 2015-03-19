# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_DEPEND="<<[{*-cpython}ssl?]>>"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.1"
PYTHON_TESTS_RESTRICTED_ABIS="*-jython"

inherit distutils

DESCRIPTION="Python FTP server library"
HOMEPAGE="https://github.com/giampaolo/pyftpdlib https://pypi.python.org/pypi/pyftpdlib"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="examples ssl test"

# Python >=3.3 provides os.sendfile().
RDEPEND="$(python_abi_depend -e "3.[3-9] *-jython" dev-python/pysendfile)
	ssl? ( $(python_abi_depend -e "*-jython" dev-python/pyopenssl) )"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)
	test? ( $(python_abi_depend -i "2.6" dev-python/unittest2) )"

# DOCS="CREDITS HISTORY.rst"
DOCS="CREDITS"

src_test() {
	testing() {
		python_execute PYTHONPATH="build-${PYTHON_ABI}/lib" "$(PYTHON)" test/test_contrib.py || return
		python_execute PYTHONPATH="build-${PYTHON_ABI}/lib" "$(PYTHON)" test/test_ftpd.py || return
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install

	if use examples; then
		insinto /usr/share/doc/${PF}
		doins -r demo test
	fi
}
