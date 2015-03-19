# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
PYTHON_DEPEND="<<[{*-cpython}ssl,{*-cpython}xml]>>"
PYTHON_RESTRICTED_ABIS="3.1 *-jython"
DISTUTILS_SRC_TEST="setup.py"

inherit distutils

DESCRIPTION="A standard Python library that abstracts away differences among multiple cloud provider APIs"
HOMEPAGE="http://libcloud.apache.org/ https://pypi.python.org/pypi/apache-libcloud"
SRC_URI="mirror://apache/${PN}/apache-${P}.tar.bz2"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE="examples ssh test"

RDEPEND="$(python_abi_depend dev-python/lockfile)
	ssh? ( $(python_abi_depend -i "2.*-cpython" dev-python/paramiko) )"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)
	test? (
		$(python_abi_depend dev-python/mock)
		$(python_abi_depend -i "2.6" dev-python/unittest2)
	)"

S="${WORKDIR}/apache-${P}"

DOCS="CHANGES.rst"

src_prepare() {
	distutils_src_prepare
	cp libcloud/test/secrets.py-dist libcloud/test/secrets.py || die "cp failed"

	# Disable usage of dev-python/lxml.
	# https://issues.apache.org/jira/browse/LIBCLOUD-642
	sed -e "s/from lxml\(\.[^[:space:]]\+\)\? import .*/raise ImportError/" -i $(grep -Elr "from lxml(\.[^[:space:]]+)? import " libcloud)

	# Fix compatibility with Python 3.2.
	# https://issues.apache.org/jira/browse/LIBCLOUD-645
	sed -e "s/'key': key.publickey().exportKey('OpenSSH')/'key': (key.publickey().exportKey('OpenSSH').decode('utf-8') if __import__('sys').version_info[0] >= 3 else key.publickey().exportKey('OpenSSH'))/" -i libcloud/compute/drivers/softlayer.py
}

src_install() {
	distutils_src_install

	delete_tests() {
		rm -r "${ED}$(python_get_sitedir)/libcloud/test"
	}
	python_execute_function -q delete_tests

	if use examples; then
		docinto examples
		dodoc example_*.py
	fi
}
