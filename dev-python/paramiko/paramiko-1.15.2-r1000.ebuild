# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
PYTHON_RESTRICTED_ABIS="*-jython *-pypy"

inherit distutils

DESCRIPTION="SSH2 protocol library"
HOMEPAGE="http://www.paramiko.org/ https://github.com/paramiko/paramiko https://pypi.python.org/pypi/paramiko"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"
IUSE="doc examples"

RDEPEND="$(python_abi_depend ">=dev-python/ecdsa-0.11")
	$(python_abi_depend ">=dev-python/pycrypto-2.1")"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)"

src_prepare() {
	distutils_src_prepare

	# Fix compatibility with Python 3.1.
	sed -e "52s/if PY2:/if PY2 or __import__('sys').version_info[:2] == (3, 1):/" -i paramiko/buffered_pipe.py
}

src_test() {
	testing() {
		python_execute PYTHONPATH="build-${PYTHON_ABI}/lib" "$(PYTHON)" test.py --verbose
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install

	if use doc; then
		dohtml -r docs/
	fi

	if use examples; then
		insinto /usr/share/doc/${PF}
		doins -r demos
	fi
}
