# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/games-misc/lucidlife/lucidlife-0.9.2.ebuild,v 1.7 2015/02/06 21:28:20 tupone Exp $

EAPI=5

inherit autotools eutils games

DESCRIPTION="A Conway's Life simulator written in GTK+2 - fork from Gtklife"
HOMEPAGE="http://linux.softpedia.com/get/GAMES-ENTERTAINMENT/Simulation/LucidLife-26633.shtml"
SRC_URI="mirror://gentoo/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

RDEPEND="x11-libs/gtk+:2"
DEPEND="${DEPEND}
	dev-util/intltool
	virtual/pkgconfig
	sys-devel/gettext"

src_prepare() {
	epatch "${FILESDIR}"/${P}-gnome-vfs.patch \
		"${FILESDIR}"/${P}-underlink.patch
	eautoreconf
	intltoolize --force --copy --automake || die
}

src_install() {
	emake install \
		desktopdir=/usr/share/applications \
		pixmapdir=/usr/share/pixmaps \
		DESTDIR="${D}"

	prepgamesdirs

	dodoc AUTHORS ChangeLog NEWS README TODO
}