# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.1 *-jython *-pypy-*"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*"

VIRTUALX_COMMAND="cmake-utils_src_test"

inherit cmake-utils multilib python virtualx

MY_P="${PN}-qt4.8+${PV}"

DESCRIPTION="Python bindings for the Qt framework"
HOMEPAGE="https://qt-project.org/wiki/PySide"
SRC_URI="http://download.qt-project.org/official_releases/${PN}/${MY_P}.tar.bz2"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"
IUSE="X declarative designer help multimedia opengl phonon script scripttools sql svg test webkit xmlpatterns"

REQUIRED_USE="
	declarative? ( X )
	designer? ( X )
	help? ( X )
	multimedia? ( X )
	opengl? ( X )
	phonon? ( X )
	scripttools? ( X script )
	sql? ( X )
	svg? ( X )
	test? ( X )
	webkit? ( X )
"

# Minimal supported version of Qt.
QT_PV="4.7.0:4"

RDEPEND="
	$(python_abi_depend ">=dev-python/shiboken-${PV}")
	>=dev-qt/qtcore-${QT_PV}
	X? (
		>=dev-qt/qtgui-${QT_PV}[accessibility]
		>=dev-qt/qttest-${QT_PV}
	)
	declarative? ( >=dev-qt/qtdeclarative-${QT_PV} )
	designer? ( || ( dev-qt/designer:4 <dev-qt/qtgui-4.8.5:4 ) )
	help? ( >=dev-qt/qthelp-${QT_PV} )
	multimedia? ( >=dev-qt/qtmultimedia-${QT_PV} )
	opengl? ( >=dev-qt/qtopengl-${QT_PV} )
	phonon? ( || (
		media-libs/phonon[qt4(+)]
		>=dev-qt/qtphonon-${QT_PV}
	) )
	script? ( >=dev-qt/qtscript-${QT_PV} )
	sql? ( >=dev-qt/qtsql-${QT_PV} )
	svg? ( >=dev-qt/qtsvg-${QT_PV}[accessibility] )
	webkit? ( >=dev-qt/qtwebkit-${QT_PV} )
	xmlpatterns? ( >=dev-qt/qtxmlpatterns-${QT_PV} )
"
DEPEND="${RDEPEND}
	>=dev-qt/qtgui-${QT_PV}
"

S=${WORKDIR}/${MY_P}

DOCS=(ChangeLog)

src_prepare() {
	# Fix generated pkgconfig file to require the shiboken
	# library suffixed with the correct python version.
	sed -i -e '/^Requires:/ s/shiboken$/&@SHIBOKEN_PYTHON_SUFFIX@/' \
		libpyside/pyside.pc.in || die

	if use prefix; then
		cp "${FILESDIR}"/rpath.cmake . || die
		sed -i -e '1iinclude(rpath.cmake)' CMakeLists.txt || die
	fi
}

src_configure() {
	configuration() {
		local mycmakeargs=(
			-DPYTHON_SUFFIX="-python${PYTHON_ABI}"
			$(cmake-utils_use_build test TESTS)
			$(cmake-utils_use_disable X QtGui)
			$(cmake-utils_use_disable X QtTest)
			$(cmake-utils_use_disable declarative QtDeclarative)
			$(cmake-utils_use_disable designer QtDesigner)
			$(cmake-utils_use_disable designer QtUiTools)
			$(cmake-utils_use_disable help QtHelp)
			$(cmake-utils_use_disable multimedia QtMultimedia)
			$(cmake-utils_use_disable opengl QtOpenGL)
			$(cmake-utils_use_disable phonon)
			$(cmake-utils_use_disable script QtScript)
			$(cmake-utils_use_disable scripttools QtScriptTools)
			$(cmake-utils_use_disable sql QtSql)
			$(cmake-utils_use_disable svg QtSvg)
			$(cmake-utils_use_disable webkit QtWebKit)
			$(cmake-utils_use_disable xmlpatterns QtXmlPatterns)
		)

		if use phonon && has_version "media-libs/phonon[qt4(+)]"; then
			mycmakeargs+=(
				-DQT_PHONON_INCLUDE_DIR="${EPREFIX}/usr/include/phonon"
				-DQT_PHONON_LIBRARY_RELEASE="${EPREFIX}/usr/$(get_libdir)/libphonon.so"
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
		BUILD_DIR="${S}_${PYTHON_ABI}" virtualmake
	}
	python_enable_pyc
	python_execute_function testing
	python_disable_pyc
}

src_install() {
	installation() {
		BUILD_DIR="${S}_${PYTHON_ABI}" cmake-utils_src_install
		mv "${ED}"usr/$(get_libdir)/pkgconfig/${PN}{,-python${PYTHON_ABI}}.pc
	}
	python_execute_function installation
}
