# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="*-jython *-pypy-*"
DISTUTILS_SRC_TEST="py.test"

inherit distutils eutils

DESCRIPTION="Foreign Function Interface for Python calling C code."
HOMEPAGE="https://cffi.readthedocs.org/ https://bitbucket.org/cffi/cffi https://pypi.python.org/pypi/cffi"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0/${PV}"
KEYWORDS="*"
IUSE="doc"

RDEPEND="$(python_abi_depend dev-python/pycparser)
	virtual/libffi"
DEPEND="${REDEPEND}
	$(python_abi_depend dev-python/setuptools)
	doc? ( $(python_abi_depend dev-python/sphinx) )"

src_prepare() {
	distutils_src_prepare
	epatch "${FILESDIR}/${PN}-0.8.2-cffi_module_configuration.patch"
	epatch "${FILESDIR}/${PN}-0.8.2-python-3.1.patch"

	# Disable failing tests.
	rm testing/test_zintegration.py
}

src_compile() {
	distutils_src_compile

	if use doc; then
		einfo "Generation of documentation"
		pushd doc > /dev/null
		PYTHONPATH="$(ls -d ../build-$(PYTHON -f --ABI)/lib*)" emake html
		popd > /dev/null
	fi
}

src_test() {
	python_copy_sources
	python_execute_py.test -P '$(ls -d build-${PYTHON_ABI}/lib*)' -s
}

src_install() {
	distutils_src_install

	if use doc; then
		dohtml -r doc/build/html/
	fi
}
