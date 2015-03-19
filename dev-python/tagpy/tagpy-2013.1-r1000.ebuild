# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="*-jython *-pypy-*"

inherit distutils

DESCRIPTION="Python Bindings for TagLib"
HOMEPAGE="http://mathema.tician.de/software/tagpy http://git.tiker.net/?p=tagpy.git https://pypi.python.org/pypi/tagpy"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="examples"

RDEPEND="$(python_abi_depend dev-libs/boost:0=[python])
	media-libs/taglib:0="
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)"

DISTUTILS_USE_SEPARATE_SOURCE_DIRECTORIES="1"

src_configure() {
	configuration() {
		python_execute "$(PYTHON)" configure.py \
			--boost-python-libname="boost_python-${PYTHON_ABI}" \
			--taglib-inc-dir="${EPREFIX}/usr/include/taglib"
	}
	python_execute_function -s configuration
}

src_install() {
	distutils_src_install

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins test/*
	fi
}
