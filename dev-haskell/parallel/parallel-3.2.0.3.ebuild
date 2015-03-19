# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-haskell/parallel/parallel-3.2.0.3.ebuild,v 1.5 2015/01/01 13:40:31 gienah Exp $

EAPI=5

# ebuild generated by hackport 0.3.9999

CABAL_FEATURES="lib profile haddock hoogle hscolour"
inherit haskell-cabal

DESCRIPTION="Parallel programming library"
HOMEPAGE="http://hackage.haskell.org/package/parallel"
SRC_URI="mirror://hackage/packages/archive/${PN}/${PV}/${P}.tar.gz"

LICENSE="BSD"
SLOT="3/${PV}"
KEYWORDS="amd64 sparc x86"
IUSE=""

RDEPEND=">=dev-haskell/deepseq-1.1:=[profile?]
		<dev-haskell/deepseq-1.4:=[profile?]
		>=dev-lang/ghc-6.10.4:="
DEPEND="${RDEPEND}
		>=dev-haskell/cabal-1.6"

src_prepare() {
	cabal_chdeps \
		'array      >= 0.1 && < 0.5' 'array      >= 0.1 && < 0.6'
}