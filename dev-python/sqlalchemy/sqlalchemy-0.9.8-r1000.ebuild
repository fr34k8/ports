# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_BDEPEND="test? ( <<[{*-cpython *-pypy}sqlite]>> )"
PYTHON_DEPEND="<<[{*-cpython *-pypy}sqlite?]>>"
PYTHON_ABI_TYPE="multiple"
PYTHON_TESTS_RESTRICTED_ABIS="*-jython"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="3.1"
DISTUTILS_SRC_TEST="nosetests"

inherit distutils

MY_PN="SQLAlchemy"
MY_P="${MY_PN}-${PV/_}"

DESCRIPTION="Python SQL toolkit and Object Relational Mapper"
HOMEPAGE="http://www.sqlalchemy.org/ https://pypi.python.org/pypi/SQLAlchemy"
SRC_URI="mirror://pypi/${MY_P:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="doc examples mssql mysql postgres +sqlite test"

RDEPEND="$(python_abi_depend dev-python/setuptools)
	mssql? ( $(python_abi_depend -e "3.* *-jython *-pypy" dev-python/pymssql) )
	mysql? ( $(python_abi_depend -e "3.* *-jython" dev-python/mysql-python) )
	postgres? ( $(python_abi_depend -e "*-jython *-pypy" dev-python/psycopg:2) )"
DEPEND="${RDEPEND}
	test? ( $(python_abi_depend -e "${PYTHON_TESTS_RESTRICTED_ABIS}" virtual/python-mock) )"

S="${WORKDIR}/${MY_P}"

PYTHON_CFLAGS=("2.* + -fno-strict-aliasing")

DISTUTILS_GLOBAL_OPTIONS=("*-cpython --with-cextensions")

src_prepare() {
	distutils_src_prepare

	# Disable tests hardcoding function call counts specific to Python versions.
	rm -r test/aaa_profiling
}

src_test() {
	testing() {
		# Based on sqla_nose.py.
		python_execute PYTHONPATH="$(ls -d build-${PYTHON_ABI}/lib*):$(ls -d build-${PYTHON_ABI}/lib*/sqlalchemy/testing/plugin)" "$(PYTHON)" -c "import nose, noseplugin; nose.main(addplugins=[noseplugin.NoseSQLAlchemy()])"
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install

	if use doc; then
		rm -r doc/build
		dohtml -r doc/
	fi

	if use examples; then
		insinto /usr/share/doc/${PF}
		doins -r examples
	fi
}
