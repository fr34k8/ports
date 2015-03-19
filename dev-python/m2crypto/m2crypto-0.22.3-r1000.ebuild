# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_DEPEND="<<[threads]>>"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.* *-jython *-pypy-*"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*"
# DISTUTILS_SRC_TEST="setup.py"

inherit distutils

MY_PN="M2Crypto"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="M2Crypto: A Python crypto and SSL toolkit"
HOMEPAGE="https://github.com/martinpaljak/M2Crypto https://pypi.python.org/pypi/M2Crypto"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
# IUSE="doc examples"
IUSE=""

RDEPEND="dev-libs/openssl:0="
DEPEND="${RDEPEND}
	dev-lang/swig:0
	$(python_abi_depend dev-python/setuptools)"
#	doc? ( dev-python/epydoc )

S="${WORKDIR}/${MY_P}"

PYTHON_MODULES="${MY_PN}"

src_compile() {
	distutils_src_compile

#	if use doc; then
#		einfo "Generation of documentation"
#		pushd doc > /dev/null
#		python_execute PYTHONPATH="$(ls -d ../build-$(PYTHON -f --ABI)/lib.*)" epydoc --html --output=api --name=M2Crypto M2Crypto || die "Generation of documentation failed"
#		popd > /dev/null
#	fi
}

src_install() {
	distutils_src_install

#	if use doc; then
#		dohtml -r doc/
#	fi

#	if use examples; then
#		insinto /usr/share/doc/${PF}/examples
#		doins -r demo/*
#	fi
}
