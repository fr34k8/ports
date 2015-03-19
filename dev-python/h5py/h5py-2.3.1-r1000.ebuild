# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="*-jython *-pypy-*"
DISTUTILS_SRC_TEST="setup.py"

inherit distutils

DESCRIPTION="Pythonic interface to the HDF5 binary data format"
HOMEPAGE="http://www.h5py.org/ https://github.com/h5py/h5py https://pypi.python.org/pypi/h5py"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="examples mpi test"

RDEPEND="sci-libs/hdf5:=[mpi?]
	$(python_abi_depend dev-python/numpy)
	mpi? ( $(python_abi_depend dev-python/mpi4py) )"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/cython)
	$(python_abi_depend dev-python/setuptools)
	test? ( $(python_abi_depend -i "2.6 3.1" dev-python/unittest2) )"

PYTHON_CFLAGS=("2.* + -fno-strict-aliasing")

DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES="1"

src_prepare() {
	# https://github.com/h5py/h5py/issues/439
	sed -e "s/(MPI_VERSION < 3)/defined(MPI_VERSION) \&\& &/" -i h5py/api_compat.h

	distutils_src_prepare
}

src_configure() {
	if use mpi; then
		DISTUTILS_GLOBAL_OPTIONS=("* --mpi")
	fi
}

src_install() {
	distutils_src_install

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins examples/*
	fi
}
