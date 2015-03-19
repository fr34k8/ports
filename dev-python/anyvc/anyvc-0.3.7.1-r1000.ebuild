# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="4-python"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.5 3.* *-jython"

inherit distutils

DESCRIPTION="Library to access any version control system"
HOMEPAGE="http://pypi.python.org/pypi/anyvc"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="doc git mercurial subversion"

RDEPEND="$(python_abi_depend dev-python/apipkg)
	$(python_abi_depend dev-python/execnet)
	$(python_abi_depend dev-python/py)
	git? ( $(python_abi_depend dev-python/dulwich) )
	mercurial? ( $(python_abi_depend -e "*-pypy-*" dev-vcs/mercurial) )
	subversion? ( $(python_abi_depend dev-python/subvertpy) )"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)
	doc? ( $(python_abi_depend dev-python/sphinx) )"

src_prepare() {
	distutils_src_prepare

	# Do not require hgdistver.
	sed \
		-e "/setup_requires=\[/,/\],/d" \
		-e "s/get_version_from_scm=True/version='${PV}'/" \
		-i setup.py
	sed \
		-e "/^import hgdistver$/d" \
		-e "s/version = hgdistver.get_version(root=base)/version = '${PV}'/" \
		-i docs/conf.py

	# Do not use unsupported theme options.
	sed \
		-e "/'tagline':/d" \
		-e "/'bitbucket_project':/d" \
		-i docs/conf.py
}

src_compile() {
	distutils_src_compile

	if use doc; then
		einfo "Generation of documentation"
		python_execute sphinx-build -b html docs docs_output || die "Generation of documentation failed"
	fi
}

src_install() {
	distutils_src_install

	if use doc; then
		pushd docs_output > /dev/null
		insinto /usr/share/doc/${PF}/html
		doins -r [a-z]* _static
		popd > /dev/null
	fi
}
