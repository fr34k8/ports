# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
PYTHON_RESTRICTED_ABIS="3.1 *-jython *-pypy"

inherit distutils
[[ "${PV}" == "9999" ]] && inherit git-r3

DESCRIPTION="Powerful and Pythonic XML processing library combining libxml2/libxslt with the ElementTree API."
HOMEPAGE="http://lxml.de/ https://pypi.python.org/pypi/lxml"
if [[ "${PV}" == "9999" ]]; then
	SRC_URI=""
	EGIT_REPO_URI="https://github.com/lxml/lxml"
else
	SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"
fi

LICENSE="BSD ElementTree GPL-2 PSF-2"
SLOT="0"
if [[ "${PV}" == "9999" ]]; then
	KEYWORDS=""
else
	KEYWORDS="*"
fi
IUSE="beautifulsoup3 doc examples +threads"

RDEPEND=">=dev-libs/libxml2-2.9.0
	>=dev-libs/libxslt-1.1.26
	beautifulsoup3? (
		$(python_abi_depend -i "2.*" dev-python/beautifulsoup:python-2)
		$(python_abi_depend -i "3.*" dev-python/beautifulsoup:python-3)
	)"
DEPEND="${RDEPEND}
	$([[ "${PV}" == "9999" ]] && python_abi_depend dev-python/cython)
	$(python_abi_depend dev-python/setuptools)"

PYTHON_CFLAGS=("2.* + -fno-strict-aliasing")

# Compiler warnings are suppressed without --warnings option.
DISTUTILS_GLOBAL_OPTIONS=("* --warnings")

src_compile() {
	distutils_src_compile $(use threads || echo --without-threading)
}

src_test() {
	testing() {
		local module
		for module in lxml/etree lxml/objectify; do
			ln -fs "../../$(ls -d build-${PYTHON_ABI}/lib.*)/${module}$(python_get_extension_module_suffix)" "src/${module}$(python_get_extension_module_suffix)" || die "Symlinking ${module}$(python_get_extension_module_suffix) failed with $(python_get_implementation_and_version)"
		done

		local exit_status="0" test
		for test in test.py selftest.py selftest2.py; do
			if ! python_execute PYTHONPATH="$(ls -d build-${PYTHON_ABI}/lib.*)" "$(PYTHON)" "${test}"; then
				eerror "${test} failed with $(python_get_implementation_and_version)"
				exit_status="1"
			fi
		done

		return "${exit_status}"
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install

	if use doc; then
		dohtml -r doc/html/
		dodoc *.txt
		docinto doc
		dodoc doc/*.txt
	fi

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins -r samples/*
	fi
}
