# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.1 *-jython *-pypy-*"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*"

inherit cmake-utils multilib python

DESCRIPTION="A tool for creating Python bindings for C++ libraries"
HOMEPAGE="https://qt-project.org/wiki/PySide"
SRC_URI="http://download.qt-project.org/official_releases/pyside/${P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"
IUSE="test"

RDEPEND="
	>=dev-libs/libxml2-2.6.32
	>=dev-libs/libxslt-1.1.19
	>=dev-qt/qtcore-4.7.0:4
	>=dev-qt/qtxmlpatterns-4.7.0:4
	!dev-python/apiextractor
	!dev-python/generatorrunner
"
DEPEND="${RDEPEND}
	test? (
		$(python_abi_depend dev-python/numpy)
		>=dev-qt/qtgui-4.7.0:4
		>=dev-qt/qttest-4.7.0:4
	)"

DOCS=(AUTHORS ChangeLog)

src_prepare() {
	# Fix inconsistent naming of libshiboken.so and ShibokenConfig.cmake,
	# caused by the usage of a different version suffix with python >= 3.2
	sed -i -e "/get_config_var('SOABI')/d" \
		cmake/Modules/FindPython3InterpWithDebug.cmake || die

	if use prefix; then
		cp "${FILESDIR}"/rpath.cmake . || die
		sed -i -e '1iinclude(rpath.cmake)' CMakeLists.txt || die
	fi
}

src_configure() {
	configuration() {
		local mycmakeargs=(
			$(cmake-utils_use_build test TESTS)
			-DPYTHON_EXECUTABLE="$(PYTHON -a)"
			-DPYTHON_SITE_PACKAGES="${EPREFIX}$(python_get_sitedir)"
			-DPYTHON_SUFFIX="-python${PYTHON_ABI}"
		)

		if [[ $(python_get_version -l --major) == 3 ]]; then
			mycmakeargs+=(
				-DUSE_PYTHON3=ON
				-DPYTHON3_EXECUTABLE="$(PYTHON -a)"
				-DPYTHON3_INCLUDE_DIR="${EPREFIX}$(python_get_includedir)"
				-DPYTHON3_LIBRARY="${EPREFIX}$(python_get_library)"
			)
		fi

		BUILD_DIR="${S}_${PYTHON_ABI}" cmake-utils_src_configure
	}
	python_execute_function configuration
}

src_compile() {
	compilation() {
		BUILD_DIR="${S}_${PYTHON_ABI}" cmake-utils_src_make
	}
	python_execute_function compilation
}

src_test() {
	testing() {
		BUILD_DIR="${S}_${PYTHON_ABI}" cmake-utils_src_test
	}
	python_execute_function testing
}

src_install() {
	installation() {
		BUILD_DIR="${S}_${PYTHON_ABI}" cmake-utils_src_install
		mv "${ED}"usr/$(get_libdir)/pkgconfig/${PN}{,-python${PYTHON_ABI}}.pc
	}
	python_execute_function installation
}
