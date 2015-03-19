# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="*-jython *-pypy-*"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*"

inherit distutils

DESCRIPTION="Message Passing Interface for Python"
HOMEPAGE="https://bitbucket.org/mpi4py/mpi4py http://pypi.python.org/pypi/mpi4py"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD-2"
SLOT="0"
KEYWORDS="*"
IUSE="doc examples"

DEPEND="virtual/mpi[romio]"
RDEPEND="${DEPEND}"

PYTHON_VERSIONED_EXECUTABLES=("/usr/bin/python-mpi")

src_prepare() {
	distutils_src_prepare

	# Fix building with exported LDSHARED environmental variable.
	sed -e "s/ldshared   = environ.get('LDSHARED', ldshared)/ldshared   = (split_linker_cmd(environ.get('LDSHARED'))[1] if environ.get('LDSHARED') is not None else ldshared)/" -i conf/mpidistutils.py
}

src_test() {
	testing() {
		PYTHONPATH="$(ls -d build-${PYTHON_ABI}/lib*)" mpiexec -n 2 "$(PYTHON)" test/runtests.py -v
	}
	python_execute_function testing
}

distutils_src_install_post_hook() {
	mkdir -p "$(distutils_get_intermediate_installation_image)${EPREFIX}/usr/bin"
	mv "$(distutils_get_intermediate_installation_image)${EPREFIX}"{$(python_get_sitedir)/mpi4py/bin/python-mpi,/usr/bin}
	rmdir "$(distutils_get_intermediate_installation_image)${EPREFIX}$(python_get_sitedir)/mpi4py/bin"
}

src_install() {
	distutils_src_install

	if use doc; then
		dohtml -r docs/
	fi

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins -r demo/*
	fi
}
