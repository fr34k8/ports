# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_DEPEND="python? ( <<>> )"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="*-jython *-pypy-*"

inherit autotools flag-o-matic python

DESCRIPTION="POSIX 1003.1e capabilities"
HOMEPAGE="http://people.redhat.com/sgrubb/libcap-ng/"
SRC_URI="http://people.redhat.com/sgrubb/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"
IUSE="python static-libs"

DEPEND="sys-kernel/linux-headers
	python? ( dev-lang/swig )"
RDEPEND=""

PYTHON_CFLAGS=("2.* + -fno-strict-aliasing")

pkg_setup() {
	use python && python_pkg_setup
}

src_prepare() {
	sed -e "s/AM_CONFIG_HEADER/AC_CONFIG_HEADERS/" -i configure.ac || die "sed failed"

	# Python bindings are built/tested/installed manually.
	sed -e "/^SUBDIRS/s/ python//" -i bindings/Makefile.am || die "sed failed"

	eautoreconf

	use python && python_clean_py-compile_files

	use sparc && replace-flags -O? -O0
}

src_configure() {
	econf \
		$(use_enable static-libs static) \
		$(use_with python)
}

src_compile() {
	default

	if use python; then
		python_copy_sources bindings/python

		building() {
			emake \
				CFLAGS="${CFLAGS}" \
				PYTHON_VERSION="$(python_get_version)" \
				pyexecdir="$(python_get_sitedir)" \
				pythondir="$(python_get_sitedir)"
		}
		python_execute_function -s --source-dir bindings/python building
	fi
}

src_test() {
	if [[ "${EUID}" -eq 0 ]]; then
		ewarn "Skipping tests due to root permissions."
		return
	fi

	default

	if use python; then
		testing() {
			emake \
				PYTHON_VERSION="$(python_get_version)" \
				pyexecdir="$(python_get_sitedir)" \
				pythondir="$(python_get_sitedir)" \
				TESTS_ENVIRONMENT="PYTHONPATH=..:../.libs" \
				check
		}
		python_execute_function -s --source-dir bindings/python testing
	fi
}

src_install() {
	default

	if use python; then
		installation() {
			emake \
				DESTDIR="${D}" \
				PYTHON_VERSION="$(python_get_version)" \
				pyexecdir="$(python_get_sitedir)" \
				pythondir="$(python_get_sitedir)" \
				install
		}
		python_execute_function -s --source-dir bindings/python installation

		python_clean_installation_image
	fi

	find "${ED}" -name "*.la" -delete
}

pkg_postinst() {
	use python && python_mod_optimize capng.py
}

pkg_postrm() {
	use python && python_mod_cleanup capng.py
}
