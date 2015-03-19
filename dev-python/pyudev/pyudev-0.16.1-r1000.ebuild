# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.5 *-jython"
# https://github.com/lunaryorn/pyudev/issues/52
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*"
DISTUTILS_SRC_TEST="py.test"
VIRTUALX_REQUIRED="manual"

inherit distutils virtualx

DESCRIPTION="Python binding to libudev"
HOMEPAGE="http://pyudev.readthedocs.org/ https://github.com/lunaryorn/pyudev http://pypi.python.org/pypi/pyudev"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"
IUSE="pygobject pyqt4 pyside test wxwidgets"

RDEPEND="virtual/udev
	pygobject? ( $(python_abi_depend -e "*-pypy-*" dev-python/pygobject:2) )
	pyqt4? ( $(python_abi_depend -e "*-pypy-*" dev-python/PyQt4) )
	pyside? ( dev-python/pyside )
	wxwidgets? ( $(python_abi_depend -e "3.* *-pypy-*" dev-python/wxpython) )"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)
	test? (
		$(python_abi_depend dev-python/mock)
		wxwidgets? ( ${VIRTUALX_DEPEND} )
	)"

DOCS="CHANGES.rst README.rst"

src_prepare() {
	distutils_src_prepare

	# Support old versions of udev.
	sed -i -e "s|== \('/run/udev'\)|in (\1, '/dev/.udev')|g" tests/test_core.py

	if ! use pygobject; then
		rm -f pyudev/glib.py
		sed -i -e "s|[, ]*GlibBinding()||g" tests/test_observer.py
	fi
	if ! use pyqt4; then
		rm -f pyudev/pyqt4.py
		sed -i -e "s|Qt4Binding('PyQt4')[, ]*||g" tests/test_observer.py
	fi
	if ! use pyside; then
		rm -f pyudev/pyside.py
		sed -i -e "s|Qt4Binding('PySide')[, ]*||g" tests/test_observer.py
	fi
	if ! use pyqt4 && ! use pyside; then
		rm -f pyudev/_qt_base.py
	fi
	if ! use wxwidgets; then
		rm -f pyudev/wx.py
		sed -i -e "s|[, ]*WXBinding()||g" tests/test_observer.py
	fi
	if ! use pygobject && ! use pyqt4 && ! use pyside && ! use wxwidgets; then
		rm -f tests/test_observer.py
	fi
}

src_test() {
	if use wxwidgets; then
		VIRTUALX_COMMAND="distutils_src_test" virtualmake
	else
		distutils_src_test
	fi
}
