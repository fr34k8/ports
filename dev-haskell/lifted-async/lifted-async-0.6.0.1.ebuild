# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-haskell/lifted-async/lifted-async-0.6.0.1.ebuild,v 1.1 2015/03/11 12:31:26 gienah Exp $

EAPI=5

# ebuild generated by hackport 0.4.3

CABAL_FEATURES="lib profile haddock hoogle hscolour test-suite"
inherit haskell-cabal

DESCRIPTION="Run lifted IO operations asynchronously and wait for their results"
HOMEPAGE="https://github.com/maoe/lifted-async"
SRC_URI="mirror://hackage/packages/archive/${PN}/${PV}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0/${PV}"
KEYWORDS="~amd64 ~x86"
IUSE="+monad-control-1"

RDEPEND=">=dev-haskell/async-2.0.1:=[profile?] <dev-haskell/async-2.1:=[profile?]
	>=dev-haskell/lifted-base-0.2:=[profile?] <dev-haskell/lifted-base-0.3:=[profile?]
	>=dev-haskell/transformers-base-0.4:=[profile?] <dev-haskell/transformers-base-0.5:=[profile?]
	>=dev-lang/ghc-7.4.1:=
	monad-control-1? ( >=dev-haskell/constraints-0.2:=[profile?] <dev-haskell/constraints-0.5:=[profile?]
				>=dev-haskell/monad-control-1.0:=[profile?] <dev-haskell/monad-control-1.1:=[profile?] )
	!monad-control-1? ( >=dev-haskell/monad-control-0:=[profile?] <dev-haskell/monad-control-1:=[profile?] )
"
DEPEND="${RDEPEND}
	>=dev-haskell/cabal-1.8
	test? ( dev-haskell/hunit
		dev-haskell/mtl
		dev-haskell/tasty
		>=dev-haskell/tasty-hunit-0.9 <dev-haskell/tasty-hunit-0.10
		dev-haskell/tasty-th )
"

src_configure() {
	haskell-cabal_src_configure \
		$(cabal_flag monad-control-1 monad-control-1)
}