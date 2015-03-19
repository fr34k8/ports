# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_DEPEND="python? ( <<[xml]>> )"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="*-jython *-pypy-*"

inherit autotools eutils flag-o-matic libtool multilib-minimal prefix python

DESCRIPTION="Version 2 of the library to manipulate XML files"
HOMEPAGE="http://www.xmlsoft.org/"

LICENSE="MIT"
SLOT="2"
KEYWORDS="*"
IUSE="debug examples icu ipv6 lzma python readline static-libs test"

XSTS_HOME="http://www.w3.org/XML/2004/xml-schema-test-suite"
XSTS_NAME_1="xmlschema2002-01-16"
XSTS_NAME_2="xmlschema2004-01-14"
XSTS_TARBALL_1="xsts-2002-01-16.tar.gz"
XSTS_TARBALL_2="xsts-2004-01-14.tar.gz"
XMLCONF_TARBALL="xmlts20080827.tar.gz"

SRC_URI="ftp://xmlsoft.org/${PN}/${PN}-${PV/_rc/-rc}.tar.gz
	test? (
		${XSTS_HOME}/${XSTS_NAME_1}/${XSTS_TARBALL_1}
		${XSTS_HOME}/${XSTS_NAME_2}/${XSTS_TARBALL_2}
		http://www.w3.org/XML/Test/${XMLCONF_TARBALL} )"

RDEPEND="sys-libs/zlib:0=[${MULTILIB_USEDEP}]
	icu? ( dev-libs/icu:0=[${MULTILIB_USEDEP}] )
	lzma? ( app-arch/xz-utils:0=[${MULTILIB_USEDEP}] )
	readline? ( sys-libs/readline:0= )"

DEPEND="${RDEPEND}
	dev-util/gtk-doc-am
	virtual/pkgconfig
	hppa? ( >=sys-devel/binutils-2.15.92.0.2 )"

S="${WORKDIR}/${PN}-${PV%_rc*}"

MULTILIB_CHOST_TOOLS=(
	/usr/bin/xml2-config
)

pkg_setup() {
	use python && python_pkg_setup
}

src_unpack() {
	# ${A} isn't used to avoid unpacking of test tarballs into $WORKDIR,
	# as they are needed as tarballs in ${S}/xstc instead and not unpacked
	unpack ${P/_rc/-rc}.tar.gz
	cd "${S}"

	if use test; then
		cp "${DISTDIR}/${XSTS_TARBALL_1}" \
			"${DISTDIR}/${XSTS_TARBALL_2}" \
			"${S}"/xstc/ \
			|| die "Failed to install test tarballs"
		unpack ${XMLCONF_TARBALL}
	fi
}

src_prepare() {
	DOCS=(AUTHORS ChangeLog NEWS README* TODO*)

	# Patches needed for prefix support
	epatch "${FILESDIR}"/${PN}-2.7.1-catalog_path.patch
	epatch "${FILESDIR}"/${PN}-2.8.0_rc1-winnt.patch

	eprefixify catalog.c xmlcatalog.c runtest.c xmllint.c

	# epunt_cxx

	epatch "${FILESDIR}/${PN}-2.9.1-disable_static_modules.patch"

	# Important patches from master
	epatch \
		"${FILESDIR}/${PN}-2.9.2-revert-missing-initialization.patch"

	# Python bindings are built/tested/installed manually.
	sed -e 's/$(PYTHON_SUBDIR)//' -i Makefile.am || die "sed failed"

	# Use pkgconfig to find icu to properly support multilib
	epatch "${FILESDIR}/${PN}-2.9.2-icu-pkgconfig.patch"

	eautoreconf
}

multilib_src_configure() {
	# filter seemingly problematic CFLAGS (#26320)
	filter-flags -fprefetch-loop-arrays -funroll-loops

	# USE zlib support breaks gnome2
	# (libgnomeprint for instance fails to compile with
	# fresh install, and existing) - <azarah@gentoo.org> (22 Dec 2002).

	# The meaning of the 'debug' USE flag does not apply to the --with-debug
	# switch (enabling the libxml2 debug module). See bug #100898.

	# --with-mem-debug causes unusual segmentation faults (bug #105120).

	ECONF_SOURCE="${S}" econf \
		--with-html-subdir=${PF}/html \
		--docdir="${EPREFIX}/usr/share/doc/${PF}" \
		$(use_with debug run-debug) \
		$(use_with icu) \
		$(use_enable ipv6) \
		$(use_with lzma) \
		$(multilib_native_use_with python) \
		$(multilib_native_use_with readline) \
		$(multilib_native_use_with readline history) \
		$(use_enable static-libs static)
}

multilib_src_compile() {
	default

	if multilib_is_native_abi && use python; then
		python_copy_sources python
		building() {
			emake PYTHON_INCLUDES="${EPREFIX}$(python_get_includedir)" \
				PYTHON_LIBS="$(python_get_library -l)" \
				PYTHON_SITE_PACKAGES="${EPREFIX}$(python_get_sitedir)"
		}
		python_execute_function -s --source-dir python building
	fi
}

multilib_src_test() {
	default

	if multilib_is_native_abi && use python; then
		testing() {
			emake test
		}
		python_execute_function -s --source-dir python testing
	fi
}

multilib_src_install() {
	emake DESTDIR="${D}" \
		EXAMPLES_DIR="${EPREFIX}"/usr/share/doc/${PF}/examples install

	if multilib_is_native_abi && use python; then
		installation() {
			emake DESTDIR="${D}" \
				PYTHON_LIBS="$(python_get_library -l)" \
				PYTHON_SITE_PACKAGES="${EPREFIX}$(python_get_sitedir)" \
				docsdir="${EPREFIX}/usr/share/doc/${PF}/python" \
				exampledir="${EPREFIX}/usr/share/doc/${PF}/python/examples" \
				install
		}
		python_execute_function -s --source-dir python installation

		python_clean_installation_image
	fi
}

multilib_src_install_all() {
	# on windows, xmllint is installed by interix libxml2 in parent prefix.
	# this is the version to use. the native winnt version does not support
	# symlinks, which makes repoman fail if the portage tree is linked in
	# from another location (which is my default). -- mduft
	if [[ ${CHOST} == *-winnt* ]]; then
		rm -rf "${ED}"/usr/bin/xmllint
		rm -rf "${ED}"/usr/bin/xmlcatalog
	fi

	rm -rf "${ED}"/usr/share/doc/${P}
	einstalldocs

	if ! use python; then
		rm -rf "${ED}"/usr/share/doc/${PF}/python
		rm -rf "${ED}"/usr/share/doc/${PN}-python-${PV}
	fi

	if ! use examples; then
		rm -rf "${ED}/usr/share/doc/${PF}/examples"
		rm -rf "${ED}/usr/share/doc/${PF}/python/examples"
	fi

	prune_libtool_files --modules
}

pkg_postinst() {
	if use python; then
		python_mod_optimize drv_libxml2.py libxml2.py
	fi

	# We don't want to do the xmlcatalog during stage1, as xmlcatalog will not
	# be in / and stage1 builds to ROOT=/tmp/stage1root. This fixes bug #208887.
	if [[ "${ROOT}" != "/" ]]; then
		elog "Skipping XML catalog creation for stage building (bug #208887)."
	else
		# need an XML catalog, so no-one writes to a non-existent one
		CATALOG="${EROOT}etc/xml/catalog"

		# we dont want to clobber an existing catalog though,
		# only ensure that one is there
		# <obz@gentoo.org>
		if [[ ! -e ${CATALOG} ]]; then
			[[ -d "${EROOT}etc/xml" ]] || mkdir -p "${EROOT}etc/xml"
			"${EPREFIX}"/usr/bin/xmlcatalog --create > "${CATALOG}"
			einfo "Created XML catalog in ${CATALOG}"
		fi
	fi
}

pkg_postrm() {
	if use python; then
		python_mod_cleanup drv_libxml2.py libxml2.py
	fi
}
