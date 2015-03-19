# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="4-python"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*-jython"
DISTUTILS_SRC_TEST="nosetests"

inherit distutils

MY_PN="PyDispatcher"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Multi-producer-multi-consumer signal dispatching mechanism"
HOMEPAGE="http://pydispatcher.sourceforge.net/ http://pypi.python.org/pypi/PyDispatcher"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 ~ia64 ~ppc x86"
IUSE="doc examples"

DEPEND="$(python_abi_depend dev-python/setuptools)
	doc? ( =dev-lang/python-2* )"
RDEPEND=""

S="${WORKDIR}/${MY_P}"

PYTHON_MODULES="pydispatch"

src_compile() {
	distutils_src_compile

	if use doc; then
		einfo "Generation of documentation"
		python_execute PYTHONPATH="." "$(PYTHON -2)" docs/pydoc/builddocs.py || die "Generation of documentation failed"
	fi
}

src_test() {
	distutils_src_test -P -w tests
}

src_install() {
	distutils_src_install

	if use doc; then
		insinto /usr/share/doc/${PF}/html
		doins -r docs/{images,index.html,style}

		dohtml -r *.html
	fi

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins examples/*
	fi
}
