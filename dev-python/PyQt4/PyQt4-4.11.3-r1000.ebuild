# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
PYTHON_RESTRICTED_ABIS="*-jython *-pypy"
PYTHON_EXPORT_PHASE_FUNCTIONS="1"

inherit eutils python qmake-utils toolchain-funcs

DESCRIPTION="Python bindings for the Qt toolkit"
HOMEPAGE="http://www.riverbankcomputing.com/software/pyqt/intro https://pypi.python.org/pypi/PyQt4"

if [[ "${PV}" == *_pre* ]]; then
	HG_REVISION=""
	MY_P="PyQt-x11-gpl-${PV%_pre*}-snapshot-${HG_REVISION}"
	SRC_URI="http://www.riverbankcomputing.com/static/Downloads/PyQt4/${MY_P}.tar.gz
		http://people.apache.org/~Arfrever/gentoo/${MY_P}.tar.gz"
else
	MY_P="PyQt-x11-gpl-${PV}"
	SRC_URI="mirror://sourceforge/pyqt/${MY_P}.tar.gz"
fi

LICENSE="|| ( GPL-2 GPL-3 )"
# Subslot is "_"-separated, alphabetically sorted list of "${module_name}-${module_version}" strings
# for PyQt4 modules with non-negative versions set by "version" argument of %Module directive:
# $ grep -E "^[[:space:]]*%Module\(" sip/*/*.sip | sort
# http://pyqt.sourceforge.net/Docs/sip4/directives.html#directive-%Module
SLOT="0/QtCore-1"
KEYWORDS="*"
IUSE="X dbus debug declarative designer doc examples help kde multimedia opengl phonon script scripttools sql svg webkit xmlpatterns"
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
	webkit? ( X )"

# Minimal supported version of Qt.
QT_PV="4.8.5:4"

RDEPEND="$(python_abi_depend ">=dev-python/sip-4.16.4:0=")
	>=dev-qt/qtcore-${QT_PV}
	X? (
		>=dev-qt/qtgui-${QT_PV}
		>=dev-qt/qttest-${QT_PV}
	)
	dbus? (
		$(python_abi_depend ">=dev-python/dbus-python-0.80")
		>=dev-qt/qtdbus-${QT_PV}
	)
	declarative? ( >=dev-qt/qtdeclarative-${QT_PV} )
	designer? ( >=dev-qt/designer-${QT_PV} )
	help? ( >=dev-qt/qthelp-${QT_PV} )
	multimedia? ( >=dev-qt/qtmultimedia-${QT_PV} )
	opengl? ( >=dev-qt/qtopengl-${QT_PV} )
	phonon? (
		kde? ( media-libs/phonon )
		!kde? ( || ( >=dev-qt/qtphonon-${QT_PV} media-libs/phonon ) )
	)
	script? ( >=dev-qt/qtscript-${QT_PV} )
	sql? ( >=dev-qt/qtsql-${QT_PV} )
	svg? ( >=dev-qt/qtsvg-${QT_PV} )
	webkit? ( >=dev-qt/qtwebkit-${QT_PV} )
	xmlpatterns? ( >=dev-qt/qtxmlpatterns-${QT_PV} )"
DEPEND="${RDEPEND}
	dbus? ( virtual/pkgconfig )"

S="${WORKDIR}/${MY_P}"

PYTHON_VERSIONED_EXECUTABLES=("/usr/bin/pyuic4")

src_prepare() {
	# Support qreal on arm architecture (bug 322349).
	use arm && epatch "${FILESDIR}/${PN}-4.10.3-qreal_float_support.patch"

	# Use proper include directory for phonon.
	sed \
		-e "s:VideoWidget()\":&, extra_include_dirs=[\"${EPREFIX}/usr/include/qt4/QtGui\"]:" \
		-e "s:^\s\+generate_code(\"phonon\":&, extra_include_dirs=[\"${EPREFIX}/usr/include/phonon\"]:" \
		-i configure.py || die "sed configure.py failed"

	if ! use dbus; then
		sed -e "s/^\(\s\+\)check_dbus()/\1pass/" -i configure.py || die "sed configure.py failed"
	fi

	python_copy_sources

	preparation() {
		if [[ "$(python_get_version -l --major)" == "3" ]]; then
			rm -r pyuic/uic/port_v2
		else
			rm -r pyuic/uic/port_v3
		fi
	}
	python_execute_function -s preparation
}

pyqt4_use_enable() {
	use $1 && echo --enable=${2:-Qt$(LC_ALL="C"; echo ${1^})}
}

src_configure() {
	configuration() {
		local myconf=(
			"$(PYTHON)" configure.py
			--confirm-license
			--bindir="${EPREFIX}/usr/bin"
			--destdir="${EPREFIX}$(python_get_sitedir)"
			--sipdir="${EPREFIX}/usr/share/sip"
			--assume-shared
			--no-timestamp
			--qsci-api
			$(use debug && echo --debug)
			--enable=QtCore
			--enable=QtNetwork
			--enable=QtXml
			$(pyqt4_use_enable X QtGui)
			$(pyqt4_use_enable X QtTest)
			$(pyqt4_use_enable dbus QtDBus)
			$(pyqt4_use_enable declarative)
			$(pyqt4_use_enable designer) $(use designer || echo --no-designer-plugin)
			$(pyqt4_use_enable help)
			$(pyqt4_use_enable multimedia)
			$(pyqt4_use_enable opengl QtOpenGL)
			$(pyqt4_use_enable phonon phonon)
			$(pyqt4_use_enable script)
			$(pyqt4_use_enable scripttools QtScriptTools)
			$(pyqt4_use_enable sql)
			$(pyqt4_use_enable svg)
			$(pyqt4_use_enable webkit QtWebKit)
			$(pyqt4_use_enable xmlpatterns QtXmlPatterns)
			AR="$(tc-getAR) cqs"
			CC="$(tc-getCC)"
			CFLAGS="${CFLAGS}"
			CFLAGS_RELEASE=
			CXX="$(tc-getCXX)"
			CXXFLAGS="${CXXFLAGS}"
			CXXFLAGS_RELEASE=
			LINK="$(tc-getCXX)"
			LINK_SHLIB="$(tc-getCXX)"
			LFLAGS="${LDFLAGS}"
			LFLAGS_RELEASE=
			RANLIB=
			STRIP=
		)
		python_execute "${myconf[@]}" || return

		local mod
		for mod in QtCore $(use X && echo QtGui) $(use dbus && echo QtDBus) $(use declarative && echo QtDeclarative) $(use designer && echo QtDesigner) $(use opengl && echo QtOpenGL); do
			# Run eqmake4 inside the qpy subdirectories to respect CC, CXX, CFLAGS, CXXFLAGS and LDFLAGS and avoid stripping.
			pushd qpy/${mod} > /dev/null || return
			eqmake4 $(ls w_qpy*.pro)
			popd > /dev/null || return

			# Fix insecure runpaths.
			sed -e "/^LFLAGS\s*=/s:-Wl,-rpath,${BUILDDIR}/qpy/${mod}::" -i ${mod}/Makefile || die "Fixing of runpaths failed"
		done

		# Avoid stripping of libpythonplugin.so.
		if use designer; then
			pushd designer > /dev/null || return
			eqmake4 designer.pro
			popd > /dev/null || return
		fi
	}
	python_execute_function -s configuration
}

src_compile() {
	python_src_compile
}

src_install() {
	installation() {
		# INSTALL_ROOT is used by designer/Makefile, other Makefiles use DESTDIR.
		emake DESTDIR="${T}/images/${PYTHON_ABI}" INSTALL_ROOT="${T}/images/${PYTHON_ABI}" install
	}
	python_execute_function -s installation
	python_merge_intermediate_installation_images "${T}/images"

	dodoc NEWS THANKS

	if use doc; then
		dohtml -r doc/html/*
	fi

	if use examples; then
		insinto /usr/share/doc/${PF}
		doins -r examples
	fi
}

pkg_postinst() {
	python_mod_optimize PyQt4
}

pkg_postrm() {
	python_mod_cleanup PyQt4
}
