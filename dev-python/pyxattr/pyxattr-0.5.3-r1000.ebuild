# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
PYTHON_RESTRICTED_ABIS="*-jython"
DISTUTILS_SRC_TEST="nosetests"

inherit distutils

DESCRIPTION="Filesystem extended attributes for python"
HOMEPAGE="http://pyxattr.k1024.org/ https://github.com/iustin/pyxattr https://pypi.python.org/pypi/pyxattr"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="*"
IUSE="doc"

RDEPEND="sys-apps/attr"
DEPEND="${DEPEND}
	$(python_abi_depend dev-python/setuptools)
	doc? ( $(python_abi_depend dev-python/sphinx) )"

src_prepare() {
	distutils_src_prepare
	sed -e "/extra_compile_args=/d" -i setup.py
}

src_compile() {
	distutils_src_compile

	if use doc; then
		einfo "Generation of documentation"
		PYTHONPATH="$(ls -d build-$(PYTHON -f --ABI)/lib*)" "$(PYTHON -f)" setup.py build_sphinx || die "Generation of documentation failed"
	fi
}

src_test() {
	touch "${T}/test_file"
	if ! setfattr -n user.attr -v value "${T}/test_file" &> /dev/null; then
		ewarn "Skipping tests due to missing support for extended attributes in filesystem used by build directory"
		return
	fi

	distutils_src_test
}

src_install() {
	distutils_src_install

	if use doc; then
		dohtml -r build/sphinx/html/
	fi
}
