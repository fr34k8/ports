# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
PYTHON_RESTRICTED_ABIS="3.1 *-jython *-pypy"

inherit distutils eutils fdo-mime

DESCRIPTION="Scientific PYthon Development EnviRonment"
HOMEPAGE="https://github.com/spyder-ide/spyder https://pypi.python.org/pypi/spyder"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.zip"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="doc ipython matplotlib numpy pep8 psutil +pyflakes pylint +rope scipy sphinx"

RDEPEND="$(python_abi_depend virtual/python-qt:4[X,svg,webkit])
	ipython? ( $(python_abi_depend -e "2.6 3.2" dev-python/ipython) )
	matplotlib? ( $(python_abi_depend dev-python/matplotlib) )
	numpy? ( $(python_abi_depend dev-python/numpy) )
	pep8? ( $(python_abi_depend dev-python/pep8) )
	psutil? ( $(python_abi_depend dev-python/psutil) )
	pyflakes? ( $(python_abi_depend dev-python/pyflakes) )
	pylint? ( $(python_abi_depend -e "2.6 3.2" dev-python/pylint) )
	rope? ( $(python_abi_depend -e "3.*" dev-python/rope) )
	scipy? ( $(python_abi_depend sci-libs/scipy) )
	sphinx? ( $(python_abi_depend dev-python/sphinx) )"
DEPEND="${RDEPEND}
	doc? ( $(python_abi_depend dev-python/sphinx) )"

DOCS="CHANGELOG README.md"
PYTHON_MODULES="spyderlib spyderplugins"

src_prepare() {
	distutils_src_prepare
	epatch "${FILESDIR}/${PN}-2.3.1-build.patch"

	# Fix compatibility with Python 3.2.
	# https://github.com/spyder-ide/spyder/issues/2239
	sed -e "s/u'\\\n'/__import__('spyderlib.py3compat').py3compat.u('\\\n')/" -i spyderlib/pygments_patch.py
}

src_compile() {
	distutils_src_compile

	if use doc; then
		einfo "Generation of documentation"
		python_execute PYTHONPATH="build-$(PYTHON -f --ABI)/lib" sphinx-build doc html || die "Generation of documentation failed"
	fi
}

src_install() {
	distutils_src_install

	doicon spyderlib/images/spyder.svg
	make_desktop_entry spyder Spyder spyder "Development;IDE"

	if use doc; then
		dohtml -r html/
	fi
}

pkg_postinst() {
	distutils_pkg_postinst
	fdo-mime_desktop_database_update
}

pkg_postrm() {
	distutils_pkg_postrm
	fdo-mime_desktop_database_update
}
