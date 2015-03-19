# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.6 3.1 3.2"
PYTHON_TESTS_RESTRICTED_ABIS="*-jython"

inherit distutils

DESCRIPTION="Extensions for Django"
HOMEPAGE="https://django-extensions.readthedocs.org/ https://github.com/django-extensions/django-extensions https://pypi.python.org/pypi/django-extensions"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="doc graphviz mysql postgres s3 sqlite test vcard"

RDEPEND="$(python_abi_depend dev-python/django[mysql?,postgres?,sqlite?])
	$(python_abi_depend dev-python/pygments)
	$(python_abi_depend dev-python/python-dateutil)
	$(python_abi_depend dev-python/shortuuid)
	$(python_abi_depend dev-python/six)
	$(python_abi_depend dev-python/werkzeug)
	graphviz? ( $(python_abi_depend -e "3.* *-jython" dev-python/pygraphviz) )
	s3? ( $(python_abi_depend -e "3.* *-jython *-pypy-*" dev-python/boto) )
	vcard? ( $(python_abi_depend -e "3.*" dev-python/vobject) )"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)
	doc? ( $(python_abi_depend dev-python/sphinx) )
	test? ( $(python_abi_depend dev-python/django[sqlite]) )"

DOCS="README.rst docs/AUTHORS"
PYTHON_MODULES="${PN/-/_}"

src_compile() {
	distutils_src_compile

	if use doc; then
		einfo "Generation of documentation"
		pushd docs > /dev/null
		emake html
		popd > /dev/null
	fi
}

src_test() {
	testing() {
		# Disable warnings.
		# https://github.com/django-extensions/django-extensions/issues/570
		python_execute PYTHONPATH="build-${PYTHON_ABI}/lib" PYTHONWARNINGS="" "$(PYTHON)" run_tests.py
	}
	python_execute_function testing
}

src_install() {
	distutils_src_install

	if use doc; then
		dohtml -r docs/_build/html/
	fi
}
