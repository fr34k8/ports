# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"

inherit qmake-utils

MY_P="QScintilla-gpl-${PV}"

DESCRIPTION="A Qt port of Neil Hodgson's Scintilla C++ editor class"
HOMEPAGE="http://www.riverbankcomputing.co.uk/software/qscintilla/intro"
SRC_URI="mirror://sourceforge/pyqt/${MY_P}.tar.gz"

LICENSE="|| ( GPL-2 GPL-3 )"
# Subslot based on first component of VERSION from Qt4Qt5/qscintilla.pro
SLOT="0/11"
KEYWORDS="*"
IUSE="designer doc"

DEPEND="
	dev-qt/qtcore:4
	dev-qt/qtgui:4
	designer? ( dev-qt/designer:4 )
"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

src_configure() {
	einfo "Configuration of qscintilla"
	pushd Qt4Qt5 > /dev/null
	eqmake4
	popd > /dev/null

	if use designer; then
		einfo "Configuration of designer plugin"
		pushd designer-Qt4Qt5 > /dev/null
		# Avoid using of system Qsci/* headers and system libqscintilla2.so during building of libqscintillaplugin.so.
		CXXFLAGS="${CXXFLAGS}${CXXFLAGS:+ }-I../Qt4Qt5" LDFLAGS="${LDFLAGS}${LDFLAGS:+ }-L../Qt4Qt5" eqmake4
		popd > /dev/null
	fi
}

src_compile() {
	einfo "Building of qscintilla"
	pushd Qt4Qt5 > /dev/null
	emake
	popd > /dev/null

	if use designer; then
		einfo "Building of designer plugin"
		pushd designer-Qt4Qt5 > /dev/null
		emake
		popd > /dev/null
	fi
}

src_install() {
	einfo "Installation of qscintilla"
	pushd Qt4Qt5 > /dev/null
	emake INSTALL_ROOT="${D}" install
	popd > /dev/null

	if use designer; then
		einfo "Installation of designer plugin"
		pushd designer-Qt4Qt5 > /dev/null
		emake INSTALL_ROOT="${D}" install
		popd > /dev/null
	fi

	dodoc NEWS

	if use doc; then
		dohtml doc/html-Qt4Qt5/*
		insinto /usr/share/doc/${PF}
	fi
}
