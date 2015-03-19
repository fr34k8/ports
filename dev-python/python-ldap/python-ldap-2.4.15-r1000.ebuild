# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="3.* *-jython"

inherit distutils multilib

DESCRIPTION="Python modules for implementing LDAP clients"
HOMEPAGE="http://python-ldap.org/ http://sourceforge.net/projects/python-ldap/ https://pypi.python.org/pypi/python-ldap"
SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"

LICENSE="PSF-2"
SLOT="0"
KEYWORDS="*"
# IUSE="doc examples sasl ssl"
IUSE="examples sasl ssl"

RDEPEND="$(python_abi_depend dev-python/pyasn1)
	$(python_abi_depend dev-python/pyasn1-modules)
	>=net-nds/openldap-2.4.11[sasl?]
	sasl? ( dev-libs/cyrus-sasl )"
DEPEND="${RDEPEND}
	$(python_abi_depend dev-python/setuptools)"
#	doc? ( $(python_abi_depend dev-python/sphinx) )

DOCS="CHANGES README"
PYTHON_MODULES="dsml.py ldap ldapurl.py ldif.py"

src_prepare() {
	distutils_src_prepare

	local defines extra_link_args include_dirs libs
	libs="lber ldap_r"

	if use elibc_glibc; then
		libs+=" resolv"
	fi

	if use sasl; then
		include_dirs+=" ${EPREFIX}/usr/include/sasl"
		defines+=" HAVE_SASL"
		libs+=" sasl2"
	fi

	if use ssl; then
		defines+=" HAVE_TLS"
		libs+=" ssl crypto"
	fi

	sed \
		-e "s:^\(library_dirs =\).*:\1:" \
		-e "s:^\(include_dirs =\).*:\1 ${include_dirs}:" \
		-e "s:^\(defines =\).*:\1 ${defines}:" \
		-e "s:^\(libs =\).*:\1 ${libs}:" \
		-i setup.cfg || die "sed failed"
}

src_compile() {
	distutils_src_compile

#	if use doc; then
#		einfo "Generation of documentation"
#		pushd Doc > /dev/null
#		PYTHONPATH="$(ls -d ../build-$(PYTHON -f --ABI)/lib*)" emake html
#		popd > /dev/null
#	fi
}

src_install() {
	distutils_src_install

#	if use doc; then
#		dohtml -r Doc/.build/html/
#	fi

	if use examples; then
		insinto /usr/share/doc/${PF}/examples
		doins -r Demo/*
	fi
}
