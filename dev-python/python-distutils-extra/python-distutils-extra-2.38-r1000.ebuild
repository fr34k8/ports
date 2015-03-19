# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"

inherit distutils

DESCRIPTION="Enhancements to Python's distutils"
HOMEPAGE="https://launchpad.net/python-distutils-extra"
SRC_URI="http://launchpad.net/python-distutils-extra/trunk/${PV}/+download/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

DEPEND="$(python_abi_depend dev-python/setuptools)"
RDEPEND="${DEPEND}"

DOCS="doc/FAQ doc/README doc/setup.cfg.example doc/setup.py.example"
PYTHON_MODULES="DistUtilsExtra"

src_prepare() {
	distutils_src_prepare

	# Disable broken tests.
	sed \
		-e "s/test_desktop/_&/" \
		-e "s/test_po(/_&/" \
		-e "s/test_policykit/_&/" \
		-e "s/test_requires_provides/_&/" \
		-i test/auto.py

	# Fix compatibility with Jython.
	# https://bugs.launchpad.net/python-distutils-extra/+bug/1019653
	sed \
		-e "s:import unittest, shutil, tempfile, os, os.path, subprocess, re:&, sys:" \
		-e "s:'/proc/self/exe':sys.executable:" \
		-i test/auto.py

	# Fix compatibility with Python 3.1.
	# https://bugs.launchpad.net/python-distutils-extra/+bug/1028589
	sed -e "s/errors=//g" -i DistUtilsExtra/auto.py
}

src_test() {
	# 5 tests fail with disabled byte-compilation.
	python_enable_byte-compilation

	# https://bugs.launchpad.net/python-distutils-extra/+bug/951257
	unset PYTHONWARNINGS

	testing() {
		python_execute PYTHONPATH="build-${PYTHON_ABI}/lib" "$(PYTHON)" test/auto.py
	}
	python_execute_function testing

	python_disable_byte-compilation
}
