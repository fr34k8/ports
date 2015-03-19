# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_DEPEND="<<[xml]>>"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.* *-jython *-pypy-*"

inherit bash-completion-r1 distutils eutils versionator

MY_P=${PN}-${PV}
SERIES=$(get_version_component_range 1-2)

DESCRIPTION="Bazaar is a next generation distributed version control system."
HOMEPAGE="http://bazaar-vcs.org/ https://pypi.python.org/pypi/bzr"
#SRC_URI="http://bazaar-vcs.org/releases/src/${MY_P}.tar.gz"
SRC_URI="http://launchpad.net/bzr/${SERIES}/${PV}/+download/${MY_P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="curl doc +sftp test"

RDEPEND="curl? ( $(python_abi_depend dev-python/pycurl) )
	sftp? ( $(python_abi_depend dev-python/paramiko) )"

DEPEND="test? (
		${RDEPEND}
		|| (
			$(python_abi_depend dev-python/pyftpdlib)
			$(python_abi_depend dev-python/medusa)
		)
		$(python_abi_depend dev-python/subunit)
		$(python_abi_depend ">=dev-python/testtools-0.9.5")
	)"

S="${WORKDIR}/${MY_P}"

PYTHON_CFLAGS=("2.* + -fno-strict-aliasing")

DOCS="doc/*.txt"
PYTHON_MODULES="bzrlib"

src_prepare() {
	distutils_src_prepare

	# Don't regenerate .c files from .pyx when Cython or Pyrex is found.
	epatch "${FILESDIR}/${PN}-2.4.2-no-pyrex-cython.patch"
}

src_test() {
	# Some tests expect the usual pyc compiling behaviour.
	python_enable_pyc

	# Define tests which are known to fail below.
	local skip_tests="("
	# https://bugs.launchpad.net/bzr/+bug/850676
	skip_tests+="per_transport.TransportTests.test_unicode_paths.*|"
	# libcurl cannot verify SSL certs
	# https://bugs.launchpad.net/bzr/+bug/82086
	skip_tests+="per_transport.TransportTests.test_clone|per_transport.TransportTests.test_connection_sharing|per_transport.TransportTests.test_copy_to|per_transport.TransportTests.test_get|per_transport.TransportTests.test_get_bytes|per_transport.TransportTests.test_get_bytes_unknown_file|per_transport.TransportTests.test_get_directory_read_gives_ReadError|per_transport.TransportTests.test_get_unknown_file|per_transport.TransportTests.test_has|per_transport.TransportTests.test_has_root_works|per_transport.TransportTests.test_readv|per_transport.TransportTests.test_readv_out_of_order|per_transport.TransportTests.test_readv_short_read|per_transport.TransportTests.test_readv_with_adjust_for_latency|per_transport.TransportTests.test_readv_with_adjust_for_latency_with_big_file|per_transport.TransportTests.test_reuse_connection_for_various_paths|test_read_bundle.TestReadMergeableBundleFromURL.test_read_mergeable_respects_possible_transports|test_read_bundle.TestReadMergeableBundleFromURL.test_read_mergeable_from_url|test_read_bundle.TestReadMergeableBundleFromURL.test_read_fail|test_http.TestActivity.test_readv|test_http.TestActivity.test_post|test_http.TestActivity.test_has|test_http.TestActivity.test_get"
	skip_tests+=")"
	if [[ -n ${skip_tests} ]]; then
		einfo "Skipping tests known to fail: ${skip_tests}"
	fi

	testing() {
		LC_ALL="C" "$(PYTHON)" bzr --no-plugins selftest ${skip_tests:+-x} ${skip_tests}
	}
	python_execute_function testing

	# Just to make sure we don't hit any errors on later stages.
	python_disable_pyc
}

src_install() {
	distutils_src_install --install-data "${EPREFIX}/usr/share"

	if use doc; then
		docinto developers
		dodoc -r doc/developers/*
		local dir
		for dir in mini-tutorial tutorials user-{guide,reference}; do
			docinto ${dir}
			dodoc -r doc/en/${dir}/*
		done
	fi

	dobashcomp contrib/bash/bzr
}
