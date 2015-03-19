# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="4-python"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.* *-jython"

inherit distutils

DESCRIPTION="Python package to handle polygonal shapes in 2D"
HOMEPAGE="http://www.j-raedler.de/projects/polygon/ https://github.com/jraedler/Polygon2"
SRC_URI="mirror://github/jraedler/Polygon${PV:0:1}/Polygon-${PV}.zip"

LICENSE="LGPL-2"
SLOT="2"
KEYWORDS="amd64 x86"
IUSE="numpy"

RDEPEND="numpy? ( $(python_abi_depend -e "*-pypy-*" dev-python/numpy) )"
DEPEND="${RDEPEND}
	app-arch/unzip"

S="${WORKDIR}/Polygon-${PV}"

PYTHON_CFLAGS=("2.* + -fno-strict-aliasing")

DOCS="HISTORY doc/Polygon.txt"
PYTHON_MODULES="Polygon"

src_prepare() {
	distutils_src_prepare

	# Set NumPy include path.
	sed \
		-e '/print "NumPy extension not found!"/i\        withNumPy = False' \
		-e "s/if withNumPy and numPyIncludePath:/if withNumPy:/" \
		-e "s/inc.append(numPyIncludePath)/inc.append(numpy.get_include())/" \
		-i setup.py

	if ! use numpy; then
		sed -e "s/withNumPy=True/withNumPy=False/" -i setup.py
	fi
}

src_test() {
	testing() {
		python_execute PYTHONPATH="$(ls -d build-${PYTHON_ABI}/lib.*)" "$(PYTHON)" test/Test.py
	}
	python_execute_function testing
}
