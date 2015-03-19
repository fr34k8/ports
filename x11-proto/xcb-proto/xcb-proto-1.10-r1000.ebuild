# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_DEPEND="<<[xml]>>"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="*-jython *-pypy-*"
XORG_MULTILIB="yes"

inherit python xorg-2

DESCRIPTION="X C-language Bindings protocol headers"
HOMEPAGE="http://xcb.freedesktop.org/"
EGIT_REPO_URI="git://anongit.freedesktop.org/git/xcb/proto"
[[ ${PV} != 9999* ]] && \
	SRC_URI="http://xcb.freedesktop.org/dist/${P}.tar.bz2"

KEYWORDS="*"
IUSE=""

RDEPEND=""
DEPEND="${RDEPEND}
	dev-libs/libxml2"

src_prepare() {
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
		BUILD_DIR="${S}-${PYTHON_ABI}" autotools-multilib_src_test
	}
	python_execute_function testing
}

src_install() {
	installation() {
		BUILD_DIR="${S}-${PYTHON_ABI}" xorg-2_src_install
	}
	python_execute_function installation

	sed -e "/^pythondir=/s:\(^pythondir=\).*:\1/dev/null:" -i "${ED}"usr/lib*/pkgconfig/xcb-proto.pc || die "sed failed"
}

pkg_postinst() {
	python_mod_optimize xcbgen
}

pkg_postrm() {
	python_mod_cleanup xcbgen
}
