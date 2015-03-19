# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-haskell/tf-random/tf-random-0.5.ebuild,v 1.3 2015/02/15 18:49:38 slyfox Exp $

EAPI=5

# ebuild generated by hackport 0.4.9999

CABAL_FEATURES="lib profile" # non-ASCII in .cabal: haddock hoogle hscolour"
inherit haskell-cabal

DESCRIPTION="High-quality splittable pseudorandom number generator"
HOMEPAGE="http://hackage.haskell.org/package/tf-random"
SRC_URI="mirror://hackage/packages/archive/${PN}/${PV}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0/${PV}"
KEYWORDS="~alpha ~amd64 ~ia64 ~ppc ~ppc64 ~sparc ~x86"
IUSE=""

RDEPEND=">=dev-haskell/primitive-0.3:=[profile?]
	dev-haskell/random:=[profile?]
	>=dev-lang/ghc-7.4.1:=
"
DEPEND="${RDEPEND}
	>=dev-haskell/cabal-1.8
"