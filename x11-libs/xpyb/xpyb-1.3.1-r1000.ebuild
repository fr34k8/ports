# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.* *-jython *-pypy-*"

inherit python xorg-2

DESCRIPTION="XCB-based Python bindings for the X Window System"
HOMEPAGE="http://xcb.freedesktop.org/"
#EGIT_REPO_URI="git://anongit.freedesktop.org/git/xcb/xpyb"
SRC_URI="http://xcb.freedesktop.org/dist/${P}.tar.bz2"

KEYWORDS="*"
IUSE="selinux"

RDEPEND=">=x11-libs/libxcb-1.7
	$(python_abi_depend ">=x11-proto/xcb-proto-1.7.1")"
DEPEND="${RDEPEND}"

PYTHON_CFLAGS=("2.* + -fno-strict-aliasing")

PATCHES=(
	"${FILESDIR}/${P}-xcb-proto-1.9.patch"
)
DOCS=(NEWS README)

pkg_setup() {
	python_pkg_setup

	xorg-2_pkg_setup
	XORG_CONFIGURE_OPTIONS=(
		$(use_enable selinux)
	)
}

src_prepare() {
	# Avoid needless changes in sys.path.
	sed -e "s/-p \$(XCBPROTO_XCBPYTHONDIR) //" -i src/Makefile.{am,in}

	python_clean_py-compile_files
	xorg-2_src_prepare
}

src_configure() {
	configuration() {
		BUILD_DIR="${S}-${PYTHON_ABI}" xorg-2_src_configure
	}
	python_execute_function configuration
}

src_compile() {
	building() {
		BUILD_DIR="${S}-${PYTHON_ABI}" xorg-2_src_compile
	}
	python_execute_function building
}

src_test() {
	testing() {
		BUILD_DIR="${S}-${PYTHON_ABI}" autotools-utils_src_test
	}
	python_execute_function testing
}

src_install() {
	installation() {
		BUILD_DIR="${S}-${PYTHON_ABI}" xorg-2_src_install
	}
	python_execute_function installation
}

pkg_postinst() {
	python_mod_optimize xcb
}

pkg_postrm() {
	python_mod_cleanup xcb
}
