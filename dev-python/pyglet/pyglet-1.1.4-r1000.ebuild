# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="4-python"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.*"

inherit distutils

DESCRIPTION="Cross-platform windowing and multimedia library"
HOMEPAGE="http://www.pyglet.org/ http://code.google.com/p/pyglet/ http://pypi.python.org/pypi/pyglet"
SRC_URI="http://pyglet.googlecode.com/files/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 ~amd64-linux ~x86-linux"
IUSE="alsa doc examples gtk +openal"

DEPEND="virtual/opengl
	alsa? ( media-libs/alsa-lib[alisp] )
	gtk? ( x11-libs/gtk+:2 )
	openal? ( media-libs/openal )"
#	ffmpeg? ( media-libs/avbin-bin )
RDEPEND="${DEPEND}"

DOCS="CHANGELOG NOTICE README"

src_install() {
	distutils_src_install

	if use doc; then
		dohtml -r doc/html/*
	fi

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins -r examples/*
		docompress -x /usr/share/doc/${PF}/examples
	fi
}
