# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"

inherit distutils

DESCRIPTION="Python socket pool"
HOMEPAGE="https://github.com/benoitc/socketpool https://pypi.python.org/pypi/socketpool"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="|| ( MIT public-domain )"
SLOT="0"
KEYWORDS="*"
IUSE="eventlet examples gevent"

RDEPEND="eventlet? ( $(python_abi_depend -e "*-jython *-pypy" dev-python/eventlet) )
	gevent? ( $(python_abi_depend -e "3.* *-jython *-pypy" dev-python/gevent) )"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)"

src_prepare() {
	distutils_src_prepare

	# Install not useless files.
	sed -e "s/data_files = DATA_FILES/data_files = []/" -i setup.py
}

src_install() {
	distutils_src_install

	if use examples; then
		docompress -x /usr/share/doc/${PF}/examples
		insinto /usr/share/doc/${PF}/examples
		doins examples/*
	fi
}
