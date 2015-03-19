# Copyright owners: Gentoo Foundation
#                   Arfrever Frehtes Taifersar Arahesis
# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
JAVA_PKG_IUSE="doc examples oracle source"

inherit java-pkg-2 java-ant-2 python

if [[ "${PV}" == *_pre* ]]; then
	inherit mercurial

	EHG_REPO_URI="https://hg.python.org/jython"
	EHG_REVISION="301e2a08b0c9"
fi

PATCHSET_REVISION="20121230"

DESCRIPTION="Implementation of Python written in Java"
HOMEPAGE="http://www.jython.org"
SRC_URI=""

LICENSE="PSF-2"
SLOT="2.7"
PYTHON_ABI="${SLOT}-jython"
KEYWORDS="~*"
IUSE="+readline +ssl test +threads +xml"

CDEPEND="dev-java/ant-core:0
	dev-java/antlr:3
	dev-java/asm:4
	dev-java/bcpkix:0
	dev-java/bcprov:0
	dev-java/commons-compress:0
	dev-java/guava:17
	dev-java/icu4j:52
	dev-java/jffi:1.2
	dev-java/jline:0
	dev-java/jnr-constants:0
	>=dev-java/jnr-netdb-1.1.2-r1:1.0
	>=dev-java/jnr-posix-3.0.1-r1:3.0
	>=dev-java/libreadline-java-0.8.0
	dev-java/netty-buffer:0
	dev-java/netty-codec:0
	dev-java/netty-common:0
	dev-java/netty-handler:0
	dev-java/netty-transport:0
	dev-java/xerces:2
	java-virtuals/servlet-api:2.5
	oracle? ( dev-java/jdbc-oracle-bin:10.2 )"
RDEPEND=">=virtual/jre-1.7
	${CDEPEND}
	>=dev-java/java-config-2.1.11-r3
	!dev-java/jython:${SLOT}"
DEPEND=">=virtual/jdk-1.7
	${CDEPEND}
	>=dev-java/junit-4.11:4
	test? ( dev-java/ant-junit4:0 )"

pkg_setup() {
	java-pkg-2_pkg_setup
	python_pkg_setup
}

java_prepare() {
	EPATCH_SUFFIX="patch" epatch "${FILESDIR}/${SLOT}-${PATCHSET_REVISION}"

	find extlibs -name "*.jar" -delete
	find -name "*.py[co]" -delete

	java-pkg_jar-from --into extlibs ant-core ant.jar
	java-pkg_jar-from --into extlibs antlr-3 antlr3.jar antlr-3.1.3.jar
	java-pkg_jar-from --into extlibs asm-4 asm.jar asm-4.0.jar
	java-pkg_jar-from --into extlibs asm-4 asm-commons.jar asm-commons-4.0.jar
	java-pkg_jar-from --into extlibs asm-4 asm-util.jar asm-util-4.0.jar
	java-pkg_jar-from --into extlibs bcpkix bcpkix.jar bcpkix-jdk15on-150.jar
	java-pkg_jar-from --into extlibs bcprov bcprov.jar bcprov-jdk15on-150.jar
	java-pkg_jar-from --into extlibs commons-compress commons-compress.jar commons-compress-1.8.1.jar
	java-pkg_jar-from --into extlibs guava-17 guava.jar guava-17.0.jar
	java-pkg_jar-from --into extlibs icu4j-52 icu4j.jar icu4j-52_1.jar
	java-pkg_jar-from --into extlibs jffi-1.2 jffi.jar jffi-1.2.6.jar
	java-pkg_jar-from --into extlibs jline jline.jar jline-1.0.jar
	java-pkg_jar-from --into extlibs jnr-constants jnr-constants.jar jnr-constants-0.8.4.jar
	java-pkg_jar-from --into extlibs jnr-netdb-1.0 jnr-netdb.jar jnr-netdb-1.1.1.jar
	java-pkg_jar-from --into extlibs jnr-posix-3.0 jnr-posix.jar jnr-posix-2.4.0.jar
	java-pkg_jar-from --build-only --into extlibs junit-4 junit.jar junit-4.10.jar
	java-pkg_jar-from --into extlibs libreadline-java libreadline-java.jar libreadline-java-0.8.jar
	java-pkg_jar-from --into extlibs netty-buffer netty-buffer.jar netty-buffer-4.0.20.Final.jar
	java-pkg_jar-from --into extlibs netty-codec netty-codec.jar netty-codec-4.0.20.Final.jar
	java-pkg_jar-from --into extlibs netty-common netty-common.jar netty-common-4.0.20.Final.jar
	java-pkg_jar-from --into extlibs netty-handler netty-handler.jar netty-handler-4.0.20.Final.jar
	java-pkg_jar-from --into extlibs netty-transport netty-transport.jar netty-transport-4.0.20.Final.jar
	java-pkg_jar-from --into extlibs servlet-api-2.5 servlet-api.jar servlet-api-2.5.jar
	java-pkg_jar-from --into extlibs xerces-2 xercesImpl.jar xercesImpl-2.11.0.jar

	# Dependencies of dev-java/antlr:3.
	java-pkg_jar-from --build-only --into extlibs antlr antlr.jar antlr-2.7.7.jar
	java-pkg_jar-from --build-only --into extlibs stringtemplate stringtemplate.jar stringtemplate-3.2.1.jar

	# Dependency of >=dev-java/jnr-netdb-1.1.2-r1:1.0 and >=dev-java/jnr-posix-3.0.1-r1:3.0.
	java-pkg_jar-from --build-only --into extlibs jnr-ffi-1 jnr-ffi.jar jnr-ffi-0.7.10.jar

	# Dependency of >=dev-java/junit-4.11:4.
	java-pkg_jar-from --build-only --into extlibs hamcrest-core-1.3 hamcrest-core.jar

	echo "has.repositories.connection=false" > ant.properties
	echo "templates.lazy=false" >> ant.properties

	if use oracle; then
		echo "oracle.jar=$(java-pkg-getjar jdbc-oracle-bin-10.2 ojdbc14.jar)" >> ant.properties
	fi
}

src_compile() {
	if [[ -n "${JYTHON_REGENERATE_FILES}" ]]; then
		EPYTHON="python2" ant template
	fi

	eant developer-build $(use_doc javadoc)
}

src_test() {
	ANT_TASKS="ant-junit4" nonfatal eant prepare-test javatest launchertest regrtest-unix
}

src_install() {
	dodoc ACKNOWLEDGMENTS NEWS README.txt

	pushd dist > /dev/null
	java-pkg_newjar "${PN}-dev.jar"

	local java_args="-Dpython.home=${EPREFIX}/usr/share/${PN}-${SLOT}"
	java_args+=" -Dpython.cachedir=\$([[ -n \"\${JYTHON_SYSTEM_CACHEDIR}\" ]] && echo ${EPREFIX}/var/cache/${PN}/${SLOT}-\$(id -un) || echo \${HOME}/.jython${SLOT}-cachedir)"
	java_args+=" -Dpython.executable=${EPREFIX}/usr/bin/jython${SLOT}"
	java-pkg_dolauncher jython${SLOT} --main "org.python.util.jython" --pkg_args "${java_args}"

	java-pkg_register-optional-dependency jdbc-mysql
	java-pkg_register-optional-dependency jdbc-postgresql

	insinto /usr/share/${PN}-${SLOT}
	doins -r Lib registry
	python_clean_installation_image -q

	use doc && java-pkg_dojavadoc Doc/javadoc
	popd > /dev/null

	use examples && java-pkg_doexamples Demo/*
	use source && java-pkg_dosrc src

	if use readline; then
		sed \
			-e "s/#\(python.console=org.python.util.ReadlineConsole\)/\1/" \
			-e "/#python.console.readlinelib=JavaReadline/a python.console.readlinelib=GnuReadline" \
			-i "${ED}usr/share/${PN}-${SLOT}/registry" || die "sed failed"
	fi
}

pkg_preinst() {
	java-pkg-2_pkg_preinst

	if has_version "<${CATEGORY}/${PN}-2.7_pre20121230:${SLOT}"; then
		# Clean Jython system cache.
		rm -fr "${EROOT}var/cache/jython/"${SLOT}-*
		JYTHON_PREPARE_SYSTEM_CACHE_DIRECTORIES="1"
	fi
}

pkg_postinst() {
	# Clean Jython system cache.
	rm -fr "${EROOT}var/cache/jython/"${SLOT}-*/*

	if [[ -n "${JYTHON_PREPARE_SYSTEM_CACHE_DIRECTORIES}" ]]; then
		_python_prepare_jython
	fi

	python_mod_optimize -f -x "/(site-packages|test|tests)/" $(python_get_libdir)

	elog
	elog "Readline can be configured in the registry:"
	elog
	elog "python.console=org.python.util.ReadlineConsole"
	elog "python.console.readlinelib=GnuReadline"
	elog
	elog "Global registry: '${EROOT}usr/share/${PN}-${SLOT}/registry'"
	elog "User registry: '~/.jython'"
	elog
}

pkg_postrm() {
	python_mod_cleanup $(python_get_libdir)

	if ! has_version "${CATEGORY}/${PN}:${SLOT}"; then
		# Clean Jython system cache.
		rm -fr "${EROOT}var/cache/jython/"${SLOT}-*
	fi
}
