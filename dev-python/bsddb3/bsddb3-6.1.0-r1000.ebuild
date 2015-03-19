# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.1 *-jython"

inherit db-use distutils multilib

DESCRIPTION="Python bindings for Oracle Berkeley DB"
HOMEPAGE="http://www.jcea.es/programacion/pybsddb.htm https://pypi.python.org/pypi/bsddb3"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="doc"

RDEPEND="<sys-libs/db-6.2:=
	|| (
		sys-libs/db:6.1
		sys-libs/db:6.0
		sys-libs/db:5.3
		sys-libs/db:5.2
		sys-libs/db:5.1
		sys-libs/db:5.0
		sys-libs/db:4.8
		sys-libs/db:4.7
	)
	"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)"

PYTHON_CFLAGS=("2.* + -fno-strict-aliasing")

DOCS="ChangeLog TODO.txt"

src_configure() {
	local bdb_versions=(6.1 6.0 5.3 5.2 5.1 5.0 4.8 4.7)
	if [[ -n "${BSDDB3_BDB_VERSION}" ]]; then
		if ! has "${BSDDB3_BDB_VERSION}" "${bdb_versions[@]}"; then
			die "Invalid BSDDB3_BDB_VERSION: '${BSDDB3_BDB_VERSION}'"
		fi
	else
		for BSDDB3_BDB_VERSION in "${bdb_versions[@]}"; do
			if has_version sys-libs/db:${BSDDB3_BDB_VERSION}; then
				break
			fi
		done
	fi

	DISTUTILS_GLOBAL_OPTIONS=(
		"* --berkeley-db=${EPREFIX}/usr"
		"* --berkeley-db-incdir=${EPREFIX}$(db_includedir ${BSDDB3_BDB_VERSION})"
		"* --berkeley-db-libdir=${EPREFIX}/usr/$(get_libdir)"
	)

	sed \
		-e "s/db_ver = None/db_ver = (${BSDDB3_BDB_VERSION%.*}, ${BSDDB3_BDB_VERSION#*.})/" \
		-e "s/dblib = 'db'/dblib = '$(db_libname ${BSDDB3_BDB_VERSION})'/" \
		-i setup2.py setup3.py || die "sed failed"
}

src_compile() {
	YES_I_HAVE_THE_RIGHT_TO_USE_THIS_BERKELEY_DB_VERSION="1" distutils_src_compile
}

src_test() {
	tests() {
		rm -f build
		ln -s build-${PYTHON_ABI} build

		python_execute TMPDIR="${T}/tests-${PYTHON_ABI}" "$(PYTHON)" test$(python_get_version -l --major).py -vv
	}
	python_execute_function tests
}

src_install() {
	YES_I_HAVE_THE_RIGHT_TO_USE_THIS_BERKELEY_DB_VERSION="1" distutils_src_install

	delete_tests() {
		rm -r "${ED}$(python_get_sitedir)/bsddb3/tests"
	}
	python_execute_function -q delete_tests

	if use doc; then
		dohtml -r docs/html/*
	fi
}
