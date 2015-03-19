# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_TESTS_FAILURES_TOLERANT_ABIS="*-jython"
DISTUTILS_SRC_TEST="setup.py"

inherit distutils

MY_P="PyYAML-${PV}"

DESCRIPTION="YAML parser and emitter for Python"
HOMEPAGE="http://pyyaml.org/wiki/PyYAML https://bitbucket.org/xi/pyyaml https://pypi.python.org/pypi/PyYAML"
SRC_URI="http://pyyaml.org/download/${PN}/${MY_P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE="examples libyaml"

DEPEND="libyaml? ( dev-libs/libyaml )"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

PYTHON_CFLAGS=("2.* + -fno-strict-aliasing")

PYTHON_MODULES="yaml"

pkg_setup() {
	python_pkg_setup
	DISTUTILS_GLOBAL_OPTIONS=("* $(use_with libyaml)")
}

src_prepare() {
	distutils_src_prepare

	# http://pyyaml.org/ticket/235
	sed -e "s/'Java' in sys.version/'java' in sys.platform/" -i setup.py
}

src_install() {
	distutils_src_install

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins -r examples/*
	fi
}
