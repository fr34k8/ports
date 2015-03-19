# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="*-jython *-pypy-*"
PYTHON_EXPORT_PHASE_FUNCTIONS="1"

inherit python qmake-utils

MY_P="QScintilla-gpl-${PV}"

DESCRIPTION="Python bindings for QScintilla"
HOMEPAGE="http://www.riverbankcomputing.co.uk/software/qscintilla/intro"
SRC_URI="mirror://sourceforge/pyqt/${MY_P}.tar.gz"

LICENSE="|| ( GPL-2 GPL-3 )"
SLOT="0"
KEYWORDS="*"
IUSE="debug"

DEPEND="
	$(python_abi_depend ">=dev-python/sip-4.16:0=")
	$(python_abi_depend ">=dev-python/PyQt4-4.10:0=[X]")
	~x11-libs/qscintilla-${PV}
"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}/Python"

src_prepare() {
	python_src_prepare
}

src_configure() {
	configuration() {
		local myconf=(
			"$(PYTHON)" configure.py
			--pyqt=PyQt4
			--pyqt-sipdir="${EPREFIX}/usr/share/sip"
			--apidir="${EPREFIX}/usr/share/qt4/qsci"
			--destdir="${EPREFIX}$(python_get_sitedir)/PyQt4"
			--qsci-sipdir="${EPREFIX}/usr/share/sip"
			--no-timestamp
			$(use debug && echo --debug)
		)
		python_execute "${myconf[@]}" || return

		eqmake4
	}
	python_execute_function -s configuration
}

src_compile() {
	python_src_compile
}

src_install() {
	installation() {
		emake INSTALL_ROOT="${D}" install
	}
	python_execute_function -s installation
}
