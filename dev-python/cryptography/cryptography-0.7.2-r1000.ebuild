# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
PYTHON_RESTRICTED_ABIS="*-jython"
DISTUTILS_SRC_TEST="py.test"

inherit distutils

DESCRIPTION="cryptography is a package which provides cryptographic recipes and primitives to Python developers."
HOMEPAGE="https://cryptography.io/ https://github.com/pyca/cryptography https://pypi.python.org/pypi/cryptography"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="|| ( Apache-2.0 BSD )"
SLOT="0"
KEYWORDS="*"
IUSE="doc test"

RDEPEND="dev-libs/openssl:0=
	$(python_abi_depend -e "*-pypy" dev-python/cffi:=)
	$(python_abi_depend dev-python/pyasn1)
	$(python_abi_depend dev-python/setuptools)
	$(python_abi_depend dev-python/six)
	$(python_abi_depend virtual/python-enum)"
DEPEND="${RDEPEND}
	doc? ( $(python_abi_depend dev-python/sphinx) )
	test? (
		$(python_abi_depend "~dev-python/cryptography-vectors-${PV}")
		$(python_abi_depend dev-python/iso8601)
		$(python_abi_depend dev-python/pretend)
	)"

PYTHON_CFFI_MODULES_GENERATION_COMMANDS=(
	"import cryptography.hazmat.bindings.openssl.binding; cryptography.hazmat.bindings.openssl.binding.Binding()"
	"import cryptography.hazmat.primitives.constant_time; cryptography.hazmat.primitives.constant_time._lib.Cryptography_constant_time_bytes_eq"
	"import cryptography.hazmat.primitives.padding; cryptography.hazmat.primitives.padding._lib.Cryptography_check_pkcs7_padding"
)

DOCS="AUTHORS.rst CHANGELOG.rst CONTRIBUTING.rst README.rst"

src_prepare() {
	distutils_src_prepare

	# Fix compatibility with Python 3.1.
	# int.from_bytes() and int.to_bytes() were introduced in Python 3.2.
	sed \
		-e "326s/if six.PY3:/if __import__(\"sys\").version_info[:2] >= (3, 2):/" \
		-e "356s/if six.PY3:/if __import__(\"sys\").version_info[:2] >= (3, 2):/" \
		-i src/cryptography/hazmat/backends/openssl/backend.py

	# Allow usage of python_generate_cffi_modules().
	sed -e "/^[[:space:]]*ffi\.verifier\._\?compile_module = _compile_module/d" -i src/cryptography/hazmat/bindings/utils.py
	sed -e "s/test_implicit_compile_explodes/_&/" -i tests/hazmat/bindings/test_utils.py
}

src_compile() {
	distutils_src_compile

	if use doc; then
		einfo "Generation of documentation"
		pushd docs > /dev/null
		PYTHONPATH="$(ls -d ../build-$(PYTHON -f --ABI)/lib*)" emake html
		popd > /dev/null
	fi
}

src_test() {
	python_execute_py.test -P '$(ls -d "$(pwd)/build-${PYTHON_ABI}/lib"*):$(pwd)'
}

distutils_src_install_post_hook() {
	# Force generation of Python CFFI modules by python_generate_cffi_modules().
	rm "$(distutils_get_intermediate_installation_image)$(python_get_sitedir)/cryptography/_Cryptography_cffi_"*.so
}

src_install() {
	distutils_src_install

	if use doc; then
		dohtml -r docs/_build/html/
	fi
}
