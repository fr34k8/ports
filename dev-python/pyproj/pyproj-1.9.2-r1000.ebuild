# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="4-python"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="*-jython *-pypy-*"

inherit distutils

DESCRIPTION="Python interface to PROJ.4 library"
HOMEPAGE="http://code.google.com/p/pyproj/ http://pypi.python.org/pypi/pyproj"
SRC_URI="http://pyproj.googlecode.com/files/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="doc"

DEPEND="sci-libs/proj"
RDEPEND="${DEPEND}"

PYTHON_CFLAGS=("2.* + -fno-strict-aliasing")

DISTUTILS_SETUP_FILES=("setup-proj.py")

pkg_setup() {
	python_pkg_setup

	export PROJ_INCDIR=""
	export PROJ_LIBDIR=""
}

src_prepare() {
	distutils_src_prepare

	# NumPy is not actually needed.
	sed \
		-e "/^import /s/, numpy//" \
		-e "s/numpy.get_include()//" \
		-i setup-proj.py
}

src_install() {
	distutils_src_install

	if use doc; then
		dohtml -r docs/
	fi
}
