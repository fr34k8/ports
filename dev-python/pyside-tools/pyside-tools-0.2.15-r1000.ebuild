# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
CMAKE_IN_SOURCE_BUILD="1"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.1 *-jython *-pypy-*"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="3.*"
VIRTUALX_COMMAND="cmake-utils_src_test"

inherit cmake-utils eutils python vcs-snapshot virtualx

DESCRIPTION="PySide development tools (lupdate, rcc, uic)"
HOMEPAGE="https://qt-project.org/wiki/PySide https://github.com/PySide/Tools"
SRC_URI="https://github.com/PySide/Tools/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="test"

RDEPEND="
	$(python_abi_depend ">=dev-python/pyside-1.2.0[X]")
	$(python_abi_depend ">=dev-python/shiboken-1.2.0")
	>=dev-qt/qtcore-4.7.0:4
	>=dev-qt/qtgui-4.7.0:4
"
DEPEND="${RDEPEND}
	test? ( virtual/pkgconfig )
"

src_prepare() {
	epatch "${FILESDIR}/0.2.13-fix-pysideuic-test-and-install.patch"

	python_copy_sources

	preparation() {
		if [[ "$(python_get_version -l --major)" == "3" ]]; then
			rm -fr pysideuic/port_v2
		else
			rm -fr pysideuic/port_v3
		fi

		sed -e "/pkg-config/s:shiboken:&-python${PYTHON_ABI}:" -i tests/rcc/run_test.sh || die "sed failed"
	}
	python_execute_function -s preparation
}

src_configure() {
	configuration() {
		local mycmakeargs=(
			-DPYTHON_BASENAME="-python${PYTHON_ABI}"
			-DPYTHON_SUFFIX="-python${PYTHON_ABI}"
			-DSITE_PACKAGE="$(python_get_sitedir)"
			$(cmake-utils_use_build test TESTS)
		)
		CMAKE_USE_DIR="${BUILDDIR}" cmake-utils_src_configure
	}
	python_execute_function -s configuration
}

src_compile() {
	compilation() {
		CMAKE_USE_DIR="${BUILDDIR}" cmake-utils_src_make
	}
	python_execute_function -s compilation
}

src_test() {
	testing() {
		CMAKE_USE_DIR="${BUILDDIR}" virtualmake
	}
	python_execute_function -s testing
}

src_install() {
	installation() {
		CMAKE_USE_DIR="${BUILDDIR}" cmake-utils_src_install DESTDIR="${T}/images/${PYTHON_ABI}"
	}
	python_execute_function -s installation
	python_merge_intermediate_installation_images "${T}/images"

	dodoc AUTHORS
}

pkg_postinst() {
	python_mod_optimize pysideuic
}

pkg_postrm() {
	python_mod_cleanup pysideuic
}
