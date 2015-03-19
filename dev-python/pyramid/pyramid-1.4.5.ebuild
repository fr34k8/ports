# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.1 *-jython"
DISTUTILS_SRC_TEST="setup.py"

inherit distutils

DESCRIPTION="The Pyramid web application development framework, a Pylons project"
HOMEPAGE="https://docs.pylonsproject.org/projects/pyramid https://github.com/Pylons/pyramid https://pypi.python.org/pypi/pyramid"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="BSD repoze ZPL doc? ( CC-BY-NC-SA-3.0 )"
SLOT="0"
KEYWORDS="*"
IUSE="doc test"

RDEPEND="$(python_abi_depend dev-python/chameleon)
	$(python_abi_depend dev-python/mako)
	$(python_abi_depend dev-python/pastedeploy)
	$(python_abi_depend dev-python/repoze.lru)
	$(python_abi_depend dev-python/setuptools)
	$(python_abi_depend dev-python/translationstring)
	$(python_abi_depend dev-python/venusian)
	$(python_abi_depend dev-python/webob)
	$(python_abi_depend net-zope/zope.deprecation)
	$(python_abi_depend net-zope/zope.interface)"
DEPEND="${RDEPEND}
	doc? (
		$(python_abi_depend dev-python/docutils)
		$(python_abi_depend dev-python/repoze.sphinx.autointerface)
		$(python_abi_depend dev-python/sphinx)
	)
	test? (
		$(python_abi_depend dev-python/webtest)
		$(python_abi_depend net-zope/zope.component)
	)"

DOCS="BFG_HISTORY.txt CHANGES.txt HISTORY.txt README.rst TODO.txt"

src_prepare() {
	distutils_src_prepare

	# Fix Sphinx theme.
	sed -e "/# Add and use Pylons theme/,+31d" -i docs/conf.py || die "sed failed"
}

src_compile() {
	distutils_src_compile

	if use doc; then
		einfo "Generation of documentation"
		python_execute "$(PYTHON -f)" setup.py build_sphinx || die "Generation of documentation failed"
	fi
}

src_install() {
	distutils_src_install

	delete_tests() {
		rm -r "${ED}$(python_get_sitedir)/pyramid/tests"
	}
	python_execute_function -q delete_tests

	if use doc; then
		dohtml -r build/sphinx/html/
	fi
}
