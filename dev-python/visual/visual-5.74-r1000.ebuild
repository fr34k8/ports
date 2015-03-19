# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="*-jython *-pypy-*"
PYTHON_EXPORT_PHASE_FUNCTIONS="1"

inherit eutils python versionator

MY_P="${PN}-$(delete_version_separator 2)_release"

DESCRIPTION="Real-time 3D graphics library for Python"
HOMEPAGE="http://www.vpython.org/ https://github.com/vpython/visual"
SRC_URI="http://www.vpython.org/contents/download/${MY_P}.tar.bz2"

LICENSE="Boost-1.0 HPND"
SLOT="0"
KEYWORDS="*"
IUSE="doc examples"

RDEPEND="dev-cpp/gtkglextmm:1.0=
	dev-cpp/libglademm:2.4=
	$(python_abi_depend dev-libs/boost:0=[python])
	$(python_abi_depend dev-python/numpy)
	$(python_abi_depend -i "2.*" dev-python/polygon:2)
	$(python_abi_depend -i "3.*" dev-python/polygon:3)
	$(python_abi_depend -i "2.*" dev-python/ttfquery)"
DEPEND="${RDEPEND}
	virtual/pkgconfig"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	# Verbose build.
	sed -e 's/2\?>>[[:space:]]*\$(LOGFILE).*//' -i src/Makefile.in || die "sed failed"

	# Avoid version suffix in cvisual.so.
	sed -e "s/-module/-avoid-version -module/" -i src/Makefile.in || die "sed failed"

	# Fix compatibility with Python 3.
	# https://github.com/vpython/visual/issues/2
	sed -e '/initcvisual;/a\\t\tPyInit_cvisual;' -i src/linux-symbols.map || die "sed failed"

	# Fix compatibility with Python 3.3.
	# https://github.com/vpython/visual/issues/6
	sed -e "s/cvisualmodule.\(la\|so\)/cvisual.\1/" -i src/Makefile.in || die "sed failed"

	epatch "${FILESDIR}/${P}-boost-1.50.patch"

	python_clean_py-compile_files
	python_src_prepare

	preparation() {
		sed \
			-e "s/-lboost_python/-lboost_python-${PYTHON_ABI}/" \
			-e "s/libboost_python/libboost_python-${PYTHON_ABI}/" \
			-i src/Makefile.in
	}
	python_execute_function -s preparation
}

src_configure() {
	python_src_configure \
		--with-example-dir="${EPREFIX}/usr/share/doc/${PF}/examples" \
		--with-html-dir="${EPREFIX}/usr/share/doc/${PF}/html" \
		$(use_enable doc docs) \
		$(use_enable examples)
}

src_install() {
	python_src_install
	python_clean_installation_image

	dodoc authors.txt HACKING.txt NEWS.txt
}

pkg_postinst() {
	python_mod_optimize vis visual
}

pkg_postrm() {
	python_mod_cleanup vis visual
}
