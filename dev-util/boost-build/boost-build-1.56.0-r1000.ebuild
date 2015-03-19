# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="single"
PYTHON_BDEPEND="test? ( <<>> )"
PYTHON_DEPEND="python? ( <<>> )"
PYTHON_RESTRICTED_ABIS="3.* *-jython *-pypy"

inherit eutils multilib python toolchain-funcs versionator

MY_PV="$(replace_all_version_separators _)"

DESCRIPTION="A system for large project software construction, which is simple to use and powerful."
HOMEPAGE="http://www.boost.org/doc/tools/build/index.html"
SRC_URI="mirror://sourceforge/boost/boost_${MY_PV}.tar.bz2"

LICENSE="Boost-1.0"
SLOT="0"
KEYWORDS="*"
IUSE="examples python test"

DEPEND="test? ( sys-apps/diffutils )"
RDEPEND=""

S="${WORKDIR}/boost_${MY_PV}/tools/build"

pkg_setup() {
	if use python || use test; then
		python_pkg_setup
	fi
}

src_unpack() {
	tar xjpf "${DISTDIR}/${A}" boost_${MY_PV}/tools/build || die "Unpacking failed"
}

src_prepare() {
	epatch \
		"${FILESDIR}/${PN}-1.56.0-support_dots_in_python-buildid.patch" \
		"${FILESDIR}/${PN}-1.56.0-disable_python_rpath.patch" \
		"${FILESDIR}/${PN}-1.56.0-respect_flags.patch" \
		"${FILESDIR}/${PN}-1.54.0-fix_tests.patch"

	# Disable stripping.
	sed -e 's/ -s\b//' -i src/engine/build.jam || die "sed failed"

	# Use correct libdir.
	sed -e "s/\[ .path \$(python-location) lib \]/[ .path \$(python-location) $(get_libdir) ]/" -i src/engine/build.jam || die "sed failed"

	# Force regeneration.
	rm src/engine/jambase.c || die

	# Allow full control of optimization and stripping flags when bjam is used as build system.
	sed \
		-e "s/^feature.feature optimization       : off speed space/& none/" \
		-e "s/^feature.feature debug-symbols      : on off/& none/" \
		-i src/tools/builtin.jam || die "sed failed"

	epatch_user
}

src_configure() {
	if use python; then
		sed -e "s/2.7 2.6 2.5 2.4 2.3 2.2/$(python_get_version)/" -i src/engine/build.jam || die "sed failed"
	fi
}

src_compile() {
	cd src/engine

	CC="$(tc-getCC)" ./build.sh cc -d+2 $(use_with python python "${EPREFIX}/usr") || die "Building of bjam failed"
}

src_test() {
	cd test

	DO_DIFF="1" "$(PYTHON)" test_all.py
	if [[ -s test_results.txt ]]; then
		eerror "Tests failed: $(<test_results.txt)"
		die "Tests failed"
	fi
}

src_install() {
	dobin src/engine/bin.*/{b2,bjam}

	insinto /usr/share/boost-build
	doins -r "${FILESDIR}/site-config.jam" \
		boost-build.jam src/bootstrap.jam src/build-system.jam src/*.py \
		src/build src/kernel src/options src/tools src/util

	# Delete invalid file.
	rm "${ED}usr/share/boost-build/build/project.ann.py" || die

	if ! use python; then
		rm "${ED}usr/share/boost-build/"**/*.py || die
	fi

	dodoc notes/build_dir_option.txt notes/changes.txt notes/hacking.txt notes/relative_source_paths.txt notes/release_procedure.txt

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins -r example/*
	fi
}

pkg_postinst() {
	use python && python_byte-compile_modules /usr/share/boost-build
}

pkg_postrm() {
	use python && python_clean_byte-compiled_modules /usr/share/boost-build
}
