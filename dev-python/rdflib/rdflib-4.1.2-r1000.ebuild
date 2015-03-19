# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*-jython"
DISTUTILS_SRC_TEST="nosetests"

inherit distutils

DESCRIPTION="RDFLib is a Python library for working with RDF, a simple yet powerful language for representing information."
HOMEPAGE="https://rdflib.readthedocs.org/ https://github.com/RDFLib/rdflib https://pypi.python.org/pypi/rdflib"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="berkdb examples html5lib sparql test"
REQUIRED_USE="test? ( html5lib sparql )"

RDEPEND="$(python_abi_depend dev-python/isodate)
	$(python_abi_depend -i "2.6" dev-python/ordereddict)
	$(python_abi_depend dev-python/pyparsing)
	berkdb? ( $(python_abi_depend -e "3.1 *-jython" dev-python/bsddb3) )
	html5lib? ( $(python_abi_depend -e "*-jython" dev-python/html5lib) )
	sparql? ( $(python_abi_depend dev-python/sparql-wrapper) )"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)"

DOCS="CHANGELOG.md CONTRIBUTORS"

src_prepare() {
	distutils_src_prepare
	rm **/*.py~

	# Delete unconditional dependencies on dev-python/html5lib and dev-python/sparql-wrapper.
	sed \
		-e "/kwargs\['tests_require'\] = \['html5lib'\]/d" \
		-e "s/kwargs\['install_requires'\].append('html5lib')/pass/" \
		-e "s/'pyparsing', 'SPARQLWrapper'\]/'pyparsing']/" \
		-i setup.py

	# Fix compatibility with Python 3.1.
	sed -e "s/if sys.version_info\[:2\] < (2, 7):/if sys.version_info[:2] < (2, 7) or sys.version_info[:2] == (3, 1):/" -i rdflib/compat.py rdflib/plugins/sparql/compat.py
}

src_test() {
	python_execute_nosetests -e -P '$(ls -d "${S}/build-${PYTHON_ABI}/lib")' -- -w '$([[ "$(python_get_version -l --major)" == "3" ]] && echo build/src || echo .)'
}

src_install() {
	distutils_src_install

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins -r examples/*
	fi
}
