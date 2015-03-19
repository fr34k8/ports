# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="4-python"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.5 3.* *-jython *-pypy-*"

inherit distutils eutils

DESCRIPTION="Gtk and/or Vim-based Python Integrated Development Application"
HOMEPAGE="http://pida.co.uk/ http://pypi.python.org/pypi/pida"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86 ~x86-interix ~amd64-linux ~x86-linux"
IUSE=""

RDEPEND=">=app-editors/gvim-6.3[gtk]
	$(python_abi_depend ">=dev-python/anyvc-0.3.2")
	$(python_abi_depend ">=dev-python/bpython-0.9.7[gtk]")
	$(python_abi_depend ">=dev-python/pygtk-2.8:2")
	$(python_abi_depend ">dev-python/pygtkhelpers-0.4.1")
	$(python_abi_depend virtual/python-argparse)
	$(python_abi_depend x11-libs/vte:0[python])"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)
	virtual/pkgconfig"

src_prepare() {
	distutils_src_prepare

	# Don't require argparse with Python 2.7.
	sed -e "/argparse/d" -i setup.py || die "sed failed"

	epatch "${FILESDIR}/${PN}-0.6.1-fix_implicit_declaration.patch"
	emake -C contrib/moo moo-pygtk.c
}

src_install() {
	distutils_src_install
	doicon pida/resources/pixmaps/pida-icon.png
	make_desktop_entry pida Pida pida-icon Development
}
