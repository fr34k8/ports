# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-perl/List-MoreUtils/List-MoreUtils-0.408.0.ebuild,v 1.2 2015/03/21 06:13:11 jer Exp $

EAPI=5

MODULE_AUTHOR=REHSACK
MODULE_VERSION=0.408
inherit perl-module

DESCRIPTION="Provide the missing functionality from List::Util"

SLOT="0"
KEYWORDS="~amd64 ~hppa ~x86"
IUSE="test"

RDEPEND="
	>=dev-perl/Exporter-Tiny-0.38.0
	virtual/perl-XSLoader
"
DEPEND="${RDEPEND}
	virtual/perl-ExtUtils-MakeMaker
	virtual/perl-File-Path
	virtual/perl-File-Spec
	virtual/perl-IPC-Cmd
	test? ( >=virtual/perl-Test-Simple-0.960.0 )
"

SRC_TEST="do"