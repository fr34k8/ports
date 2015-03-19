# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="4-python"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.5 3.* *-jython *-pypy-*"

inherit distutils

DESCRIPTION="PyGTKHelpers is a library to assist the building of PyGTK applications"
HOMEPAGE="http://packages.python.org/pygtkhelpers/ http://pypi.python.org/pypi/pygtkhelpers"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="LGPL-3"
SLOT="0"
KEYWORDS="amd64 ~ppc64 x86"
IUSE="doc examples"

# pygtkhelpers.forms requires flatland.
# http://discorporate.us/projects/flatland/
# https://bitbucket.org/jek/flatland
# http://pypi.python.org/pypi/flatland
RDEPEND="$(python_abi_depend dev-python/pygtk)"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)
	doc? ( $(python_abi_depend dev-python/sphinx) )"

src_prepare() {
	distutils_src_prepare

	# docs/_static/scope.jpg does not exist.
	sed -e "s/^\(html_logo =.*\)/#\1/" -i docs/conf.py || die "sed failed"
}

src_compile() {
	distutils_src_compile

	if use doc; then
		einfo "Generation of documentation"
		"$(PYTHON -f)" setup.py build_sphinx || die "Generation of documentation failed"
	fi
}

src_install() {
	distutils_src_install

	if use doc; then
		pushd build/sphinx/html > /dev/null
		insinto /usr/share/doc/${PF}/html
		doins -r [a-z]* _images _static
		popd > /dev/null
	fi

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins -r examples/*
	fi
}
