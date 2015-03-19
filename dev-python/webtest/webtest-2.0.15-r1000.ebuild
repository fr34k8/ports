# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.1"
PYTHON_TESTS_RESTRICTED_ABIS="*-jython"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*-pypy-*"
DISTUTILS_SRC_TEST="nosetests"

inherit distutils

MY_PN="WebTest"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Helper to test WSGI applications"
HOMEPAGE="https://webtest.pythonpaste.org/ https://docs.pylonsproject.org/projects/webtest https://github.com/Pylons/webtest https://pypi.python.org/pypi/WebTest"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.zip"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="doc test"

RDEPEND="$(python_abi_depend dev-python/beautifulsoup:4)
	$(python_abi_depend -i "2.6" dev-python/ordereddict)
	$(python_abi_depend dev-python/pastedeploy)
	$(python_abi_depend -e "*-jython *-pypy-*" dev-python/pyquery)
	$(python_abi_depend dev-python/six)
	$(python_abi_depend ">=dev-python/waitress-0.8.5")
	$(python_abi_depend ">=dev-python/webob-1.2")
	$(python_abi_depend dev-python/wsgiproxy2)"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)
	doc? ( $(python_abi_depend dev-python/sphinx) )
	test? (
		$(python_abi_depend dev-python/coverage)
		$(python_abi_depend dev-python/mock)
		$(python_abi_depend -i "2.6" dev-python/unittest2)
	)"

S="${WORKDIR}/${MY_P}"

DOCS="CHANGELOG.rst README.rst"

src_prepare() {
	distutils_src_prepare

	# Fix generation of documentation with WebTest not installed.
	sed -e "s/^version = pkg_resources.get_distribution(project).version$/version = '${PV}'/" -i docs/conf.py
}

src_compile() {
	distutils_src_compile

	if use doc; then
		einfo "Generation of documentation"
		python_execute PYTHONPATH="build-$(PYTHON -f --ABI)/lib" sphinx-build docs html || die "Generation of documentation failed"
	fi
}

src_install() {
	distutils_src_install

	if use doc; then
		dohtml -r html/
	fi
}
