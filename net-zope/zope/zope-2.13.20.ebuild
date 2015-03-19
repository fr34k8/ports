# Copyright owners: Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_MULTIPLE_ABIS="1"
PYTHON_RESTRICTED_ABIS="2.5 3.* *-jython *-pypy-*"

inherit distutils eutils multilib versionator

MY_PN="Zope2"
MY_P="${MY_PN}-${PV}"

DESCRIPTION="Zope 2 application server / web framework"
HOMEPAGE="http://www.zope.org http://zope2.zope.org https://pypi.python.org/pypi/Zope2 https://launchpad.net/zope2"
SRC_URI="mirror://pypi/${MY_PN:0:1}/${MY_PN}/${MY_P}.zip"

LICENSE="ZPL"
SLOT="$(get_version_component_range 1-2)"
KEYWORDS="*"
IUSE="doc"
RESTRICT="test"

RDEPEND="$(python_abi_depend net-zope/namespaces-zope[Products,Shared,Shared.DC])
	$(python_abi_depend dev-python/docutils)
	$(python_abi_depend dev-python/restrictedpython)
	$(python_abi_depend dev-python/setuptools)
	$(python_abi_depend net-zope/accesscontrol)
	$(python_abi_depend net-zope/acquisition)
	$(python_abi_depend net-zope/datetime)
	$(python_abi_depend net-zope/documenttemplate)
	$(python_abi_depend net-zope/extensionclass)
	$(python_abi_depend net-zope/initgroups)
	$(python_abi_depend net-zope/missing)
	$(python_abi_depend net-zope/multimapping)
	$(python_abi_depend net-zope/persistence)
	$(python_abi_depend net-zope/record)
	$(python_abi_depend net-zope/tempstorage)
	$(python_abi_depend net-zope/transaction)
	$(python_abi_depend net-zope/zconfig)
	$(python_abi_depend net-zope/zdaemon)
	$(python_abi_depend net-zope/zexceptions)
	$(python_abi_depend net-zope/zlog)
	$(python_abi_depend net-zope/zodb)
	$(python_abi_depend net-zope/zope.app.form)
	$(python_abi_depend net-zope/zope.browser)
	$(python_abi_depend net-zope/zope.browsermenu)
	$(python_abi_depend net-zope/zope.browserpage)
	$(python_abi_depend net-zope/zope.browserresource)
	$(python_abi_depend net-zope/zope.component)
	$(python_abi_depend net-zope/zope.configuration)
	$(python_abi_depend net-zope/zope.container)
	$(python_abi_depend net-zope/zope.contentprovider)
	$(python_abi_depend net-zope/zope.contenttype)
	$(python_abi_depend net-zope/zope.deferredimport)
	$(python_abi_depend net-zope/zope.event)
	$(python_abi_depend net-zope/zope.exceptions)
	$(python_abi_depend net-zope/zope.formlib)
	$(python_abi_depend net-zope/zope.i18n)
	$(python_abi_depend net-zope/zope.i18nmessageid)
	$(python_abi_depend net-zope/zope.interface)
	$(python_abi_depend net-zope/zope.lifecycleevent)
	$(python_abi_depend net-zope/zope.location)
	$(python_abi_depend net-zope/zope.pagetemplate)
	$(python_abi_depend net-zope/zope.processlifetime)
	$(python_abi_depend net-zope/zope.proxy)
	$(python_abi_depend net-zope/zope.ptresource)
	$(python_abi_depend net-zope/zope.publisher)
	$(python_abi_depend net-zope/zope.schema)
	$(python_abi_depend net-zope/zope.security)
	$(python_abi_depend net-zope/zope.sendmail)
	$(python_abi_depend net-zope/zope.sequencesort)
	$(python_abi_depend net-zope/zope.site)
	$(python_abi_depend net-zope/zope.size)
	$(python_abi_depend net-zope/zope.structuredtext)
	$(python_abi_depend ">=net-zope/zope.tales-3.5.0")
	$(python_abi_depend net-zope/zope.testbrowser)
	$(python_abi_depend net-zope/zope.testing)
	$(python_abi_depend net-zope/zope.traversing)
	$(python_abi_depend net-zope/zope.viewlet)
	$(python_abi_depend net-zope/zopeundo)"
DEPEND="${RDEPEND}
	doc? ( $(python_abi_depend dev-python/sphinx) )"
PDEPEND="$(python_abi_depend net-zope/btreefolder2)
	$(python_abi_depend net-zope/externalmethod)
	$(python_abi_depend net-zope/mailhost)
	$(python_abi_depend net-zope/mimetools)
	$(python_abi_depend net-zope/ofsp)
	$(python_abi_depend net-zope/pythonscripts)
	$(python_abi_depend net-zope/standardcachemanagers)
	$(python_abi_depend net-zope/zcatalog)
	$(python_abi_depend net-zope/zctextindex)"

S="${WORKDIR}/${MY_P}"

pkg_setup() {
	python_pkg_setup
	ZOPE_INSTALLATION_DIR="usr/$(get_libdir)/${PN}-${SLOT}"
}

src_prepare() {
	distutils_src_prepare
	epatch "${FILESDIR}/${PN}-2.13.20-backports.patch"
}

src_compile() {
	distutils_src_compile

	if use doc; then
		einfo "Generation of documentation"
		"$(PYTHON -f)" setup.py build_sphinx || die "Generation of documentation failed"
	fi
}

distutils_src_install_post_hook() {
	mv "$(distutils_get_intermediate_installation_image)/${ZOPE_INSTALLATION_DIR}/lib/python"{,-${PYTHON_ABI}}
}

src_install() {
	distutils_src_install --home="${ZOPE_INSTALLATION_DIR}"

	local file
	for file in "${D}${ZOPE_INSTALLATION_DIR}/bin/"*; do
		scripts_preparation() {
			cp "${file}" "${file}-${PYTHON_ABI}" || return 1
			python_convert_shebangs -q ${PYTHON_ABI} "${file}-${PYTHON_ABI}"
			sed \
				-e "/import sys/i import os\nos.environ['PYTHONPATH'] = (os.environ.get('PYTHONPATH') + ':' if os.environ.get('PYTHONPATH') is not None else '') + os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'lib', 'python-${PYTHON_ABI}'))" \
				-e "/import sys/a sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..', 'lib', 'python-${PYTHON_ABI}')))" \
				-i "${file}-${PYTHON_ABI}"
		}
		python_execute_function -q scripts_preparation

		python_generate_wrapper_scripts -f "${file}"
	done

	modules_installation() {
		local module
		for module in Products Shared Shared/DC; do
			echo "__import__('pkg_resources').declare_namespace(__name__)" > "${D}${ZOPE_INSTALLATION_DIR}/lib/python-${PYTHON_ABI}/${module}/__init__.py" || return 1
		done
	}
	python_execute_function -q modules_installation

	skel_preparation() {
		sed -e "/^ZOPE_RUN=/s/runzope/&-${PYTHON_ABI}/" -i "${D}${ZOPE_INSTALLATION_DIR}/lib/python-${PYTHON_ABI}/Zope2/utilities/skel/bin/runzope.in" || return 1
		sed -e "/^ZDCTL=/s/zopectl/&-${PYTHON_ABI}/" -i "${D}${ZOPE_INSTALLATION_DIR}/lib/python-${PYTHON_ABI}/Zope2/utilities/skel/bin/zopectl.in" || return 1
	}
	python_execute_function -q skel_preparation

	if use doc; then
		dohtml -r build/sphinx/html/
	fi

	# Copy the init script skeleton to skel directory of our installation.
	insinto "/${ZOPE_INSTALLATION_DIR}/skel"
	doins "${FILESDIR}/zope.initd"
}

pkg_postinst() {
	python_mod_optimize --allow-evaluated-non-sitedir-paths "/${ZOPE_INSTALLATION_DIR}/lib/python-\${PYTHON_ABI}"
}

pkg_postrm() {
	python_mod_cleanup --allow-evaluated-non-sitedir-paths "/${ZOPE_INSTALLATION_DIR}/lib/python-\${PYTHON_ABI}"
}
