# Distributed under the terms of the GNU General Public License v2

EAPI="5-progress"
PYTHON_ABI_TYPE="multiple"
PYTHON_DEPEND="<<[{2.6}threads]>> !build? ( <<[ssl]>> )"
PYTHON_RESTRICTED_ABIS="*-jython"
PYTHON_MODULES="_emerge portage repoman"
DISTUTILS_SRC_TEST="setup.py"

inherit distutils eutils vcs-snapshot

DESCRIPTION="Portage is the package management and distribution system for Gentoo"
HOMEPAGE="http://www.gentoo.org/proj/en/portage/index.xml"
LICENSE="GPL-2"
KEYWORDS="~*"
SLOT="0"
IUSE="build doc epydoc +ipc linguas_ru selinux xattr"
GITHUB_REPO="portage-funtoo"
GITHUB_USER="funtoo"
GITHUB_TAG="funtoo-${PVR}"
RESTRICT="mirror"

DEPEND=">=sys-apps/sed-4.0.5 sys-devel/patch
	doc? ( app-text/xmlto ~app-text/docbook-xml-dtd-4.4 )
	epydoc? ( >=dev-python/epydoc-2.0 )"
# Require sandbox-2.2 for bug #288863.
# For xattr, we can spawn getfattr and setfattr from sys-apps/attr, but that's
# quite slow, so it's not considered in the dependencies as an alternative to
# to python-3.3 / pyxattr. Also, xattr support is only tested with Linux, so
# for now, don't pull in xattr deps for other kernels.
# For whirlpool hash, require python[ssl] or python-mhash (bug #425046).
# For compgen, require bash[readline] (bug #445576).
RDEPEND="
	!build? (
		>=sys-apps/sed-4.0.5
		app-shells/bash:0[readline]
		>=app-admin/eselect-1.2
	)
	elibc_FreeBSD? ( sys-freebsd/freebsd-bin )
	elibc_glibc? ( >=sys-apps/sandbox-2.2 )
	elibc_uclibc? ( >=sys-apps/sandbox-2.2 )
	>=app-misc/pax-utils-0.1.17
	selinux? ( $(python_abi_depend "sys-libs/libselinux[python]") )
	xattr? ( kernel_linux? ( || (
		>=sys-apps/install-xattr-0.3
		$(python_abi_depend -i "2.* 3.[1-2]" dev-python/pyxattr)
	) ) )
	!<app-admin/logrotate-3.8.0"
PDEPEND="
	!build? (
		>=net-misc/rsync-2.6.4
		userland_GNU? ( >=sys-apps/coreutils-6.4 )
	)"
# coreutils-6.4 rdep is for date format in emerge-webrsync #164532
# NOTE: FEATURES=installsources requires debugedit and rsync

prefix_src_archives() {
	local x y
	for x in ${@}; do
		for y in ${SRC_ARCHIVES}; do
			echo ${y}/${x}
		done
	done
}

SRC_URI="https://www.github.com/${GITHUB_USER}/${GITHUB_REPO}/tarball/${GITHUB_TAG} -> portage-${GITHUB_TAG}.tar.gz"
S=${WORKDIR}/portage-${GITHUB_TAG}

src_prepare() {
	if ! use ipc ; then
		einfo "Disabling ipc..."
		sed -e "s:_enable_ipc_daemon = True:_enable_ipc_daemon = False:" \
			-i pym/_emerge/AbstractEbuildProcess.py || \
			die "failed to patch AbstractEbuildProcess.py"
	fi

	if use xattr && use kernel_linux ; then
		einfo "Adding FEATURES=xattr to make.globals ..."
		echo -e '\nFEATURES="${FEATURES} xattr"' >> cnf/make.globals \
			|| die "failed to append to make.globals"
	fi

	if [[ -n ${EPREFIX} ]] ; then
		einfo "Setting portage.const.EPREFIX ..."
		sed -e "s|^\(SANDBOX_BINARY[[:space:]]*=[[:space:]]*\"\)\(/usr/bin/sandbox\"\)|\\1${EPREFIX}\\2|" \
			-e "s|^\(FAKEROOT_BINARY[[:space:]]*=[[:space:]]*\"\)\(/usr/bin/fakeroot\"\)|\\1${EPREFIX}\\2|" \
			-e "s|^\(BASH_BINARY[[:space:]]*=[[:space:]]*\"\)\(/bin/bash\"\)|\\1${EPREFIX}\\2|" \
			-e "s|^\(MOVE_BINARY[[:space:]]*=[[:space:]]*\"\)\(/bin/mv\"\)|\\1${EPREFIX}\\2|" \
			-e "s|^\(PRELINK_BINARY[[:space:]]*=[[:space:]]*\"\)\(/usr/sbin/prelink\"\)|\\1${EPREFIX}\\2|" \
			-e "s|^\(EPREFIX[[:space:]]*=[[:space:]]*\"\).*|\\1${EPREFIX}\"|" \
			-i pym/portage/const.py || \
			die "Failed to patch portage.const.EPREFIX"

		einfo "Prefixing shebangs ..."
		while read -r -d $'\0' ; do
			local shebang=$(head -n1 "$REPLY")
			if [[ ${shebang} == "#!"* && ! ${shebang} == "#!${EPREFIX}/"* ]] ; then
				sed -i -e "1s:.*:#!${EPREFIX}${shebang:2}:" "$REPLY" || \
					die "sed failed"
			fi
		done < <(find . -type f -print0)

		einfo "Adjusting make.globals ..."
		sed -e 's|^SYNC=.*|SYNC="rsync://rsync.prefix.freens.org/gentoo-portage-prefix"|' \
			-e "s|^\(PORTAGE_TMPDIR=\)\(/var/tmp\)|\\1\"${EPREFIX}\\2\"|" \
			-i cnf/make.globals || die "sed failed"

		einfo "Adjusting repos.conf ..."
		sed -e "s|^\(main-repo = \).*|\\1gentoo_prefix|" \
			-e "s|^\\[gentoo\\]|[gentoo_prefix]|" \
			-e "s|^\(location = \)\(/usr/portage\)|\\1${EPREFIX}\\2|" \
			-e "s|^\(sync-uri = \).*|\\1rsync://prefix.gentooexperimental.org/gentoo-portage-prefix|" \
			-i cnf/repos.conf || die "sed failed"

		einfo "Adding FEATURES=force-prefix to make.globals ..."
		echo -e '\nFEATURES="${FEATURES} force-prefix"' >> cnf/make.globals \
			|| die "failed to append to make.globals"
	fi

	cd "${S}/cnf" || die
	if [ -f "make.conf.example.${ARCH}".diff ]; then
		patch make.conf.example "make.conf.example.${ARCH}".diff || \
			die "Failed to patch make.conf.example"
	else
		eerror ""
		eerror "Portage does not have an arch-specific configuration for this arch."
		eerror "Please notify the arch maintainer about this issue. Using generic."
		eerror ""
	fi
}

src_compile() {
	distutils_src_compile

	use doc && "$(PYTHON -f)" setup.py docbook
	use epydoc && "$(PYTHON -f)" setup.py epydoc
}

src_install() {
	# Install sbin scripts to bindir for python-exec linking
	# they will be relocated in pkg_preinst()
	distutils_src_install \
		--system-prefix="${EPREFIX}/usr" \
		--docdir="${EPREFIX}/usr/share/doc/${PF}" \
		--htmldir="${EPREFIX}/usr/share/doc/${PF}/html" \
		--sysconfdir="${EPREFIX}/etc" \
		"${@}"

	use doc && "$(PYTHON -f)" setup.py install_docbook
	use epydoc && "$(PYTHON -f)" setup.py install_epydoc

	PYGRADE_CODE="$(<"${FILESDIR}/pygrade.py")"
}

pkg_preinst() {
	# comment out sanity test until it is fixed to work
	# with the new PORTAGE_PYM_PATH
	#if [[ $ROOT == / ]] ; then
		## Run some minimal tests as a sanity check.
		#local test_runner=$(find "${ED}" -name runTests)
		#if [[ -n $test_runner && -x $test_runner ]] ; then
			#einfo "Running preinst sanity tests..."
			#"$test_runner" || die "preinst sanity tests failed"
		#fi
	#fi

	# elog dir must exist to avoid logrotate error for bug #415911.
	# This code runs in preinst in order to bypass the mapping of
	# portage:portage to root:root which happens after src_install.
	keepdir /var/log/portage/elog
	# This is allowed to fail if the user/group are invalid for prefix users.
	if chown portage:portage "${ED}"var/log/portage{,/elog} 2>/dev/null ; then
		chmod g+s,ug+rwx "${ED}"var/log/portage{,/elog}
	fi

	if has_version "<${CATEGORY}/${PN}-2.3.7" ; then
		USERPRIV_UPGRADE=true
		USERSYNC_UPGRADE=true
		REPOS_CONF_UPGRADE=true
		REPOS_CONF_SYNC=
		type -P portageq >/dev/null 2>&1 && \
			REPOS_CONF_SYNC=$("$(type -P portageq)" envvar SYNC)
	else
		USERPRIV_UPGRADE=false
		USERSYNC_UPGRADE=false
		REPOS_CONF_UPGRADE=false
	fi
}

get_ownership() {
	case ${USERLAND} in
		BSD)
			stat -f '%Su:%Sg' "${1}"
			;;
		*)
			stat -c '%U:%G' "${1}"
			;;
	esac
}

new_config_protect() {
	# Generate a ._cfg file even if the target file
	# does not exist, ensuring that the user will
	# notice the config change.
	local basename=${1##*/}
	local dirname=${1%/*}
	local i=0
	while true ; do
		local filename=$(
			echo -n "${dirname}/._cfg"
			printf "%04d" ${i}
			echo -n "_${basename}"
		)
		[[ -e ${filename} ]] || break
		(( i++ ))
	done
	echo "${filename}"
}

pkg_postinst() {
	distutils_pkg_postinst

	echo "${PYGRADE_CODE}" > "${T}/pygrade.py"
	"$(PYTHON -f)" "${T}/pygrade.py"

	if ${REPOS_CONF_UPGRADE} ; then
		einfo "Generating repos.conf"
		local repo_name=
		[[ -f ${PORTDIR}/profiles/repo_name ]] && \
			repo_name=$(< "${PORTDIR}/profiles/repo_name")
		if [[ -z ${REPOS_CONF_SYNC} ]] ; then
			REPOS_CONF_SYNC=$(grep "^sync-uri =" "${EROOT:-${ROOT}}usr/share/portage/config/repos.conf")
			REPOS_CONF_SYNC=${REPOS_CONF_SYNC##* }
		fi
		local sync_type=
		[[ ${REPOS_CONF_SYNC} == git://* ]] && sync_type=git

		if [[ ${REPOS_CONF_SYNC} == cvs://* ]]; then
			sync_type=cvs
			REPOS_CONF_SYNC=${REPOS_CONF_SYNC#cvs://}
		fi

		cat <<-EOF > "${T}/repos.conf"
		[${repo_name:-gentoo}]
		location = ${PORTDIR:-${EPREFIX}/usr/portage}
		sync-type = ${sync_type:-rsync}
		sync-uri = ${REPOS_CONF_SYNC}
		EOF

		[[ ${sync_type} == cvs ]] && echo "sync-cvs-repo = $(<"${PORTDIR}/CVS/Repository")" >> "${T}/repos.conf"

		local dest=${EROOT:-${ROOT}}etc/portage/repos.conf
		if [[ ! -f ${dest} ]] && mkdir -p "${dest}" 2>/dev/null ; then
			dest=${EROOT:-${ROOT}}etc/portage/repos.conf/${repo_name:-gentoo}.conf
		fi
		# Don't install the config update if the desired repos.conf directory
		# and config file exist, since users may accept it blindly and break
		# their config (bug #478726).
		[[ -e ${EROOT:-${ROOT}}etc/portage/repos.conf/${repo_name:-gentoo}.conf ]] || \
			mv "${T}/repos.conf" "$(new_config_protect "${dest}")"

		if [[ ${PORTDIR} == ${EPREFIX}/usr/portage ]] ; then
			einfo "Generating make.conf PORTDIR setting for backward compatibility"
			for dest in "${EROOT:-${ROOT}}etc/make.conf" "${EROOT:-${ROOT}}etc/portage/make.conf" ; do
				[[ -e ${dest} ]] && break
			done
			[[ -d ${dest} ]] && dest=${dest}/portdir.conf
			rm -rf "${T}/make.conf"
			[[ -f ${dest} ]] && cat "${dest}" > "${T}/make.conf"
			cat <<-EOF >> "${T}/make.conf"

			# Set PORTDIR for backward compatibility with various tools:
			#   gentoo-bashcomp - bug #478444
			#   euse - bug #474574
			#   euses and ufed - bug #478318
			PORTDIR="${EPREFIX}/usr/portage"
			EOF
			mkdir -p "${dest%/*}"
			mv "${T}/make.conf" "$(new_config_protect "${dest}")"
		fi
	fi

	local distdir=${PORTAGE_ACTUAL_DISTDIR-${DISTDIR}}

	if ${USERSYNC_UPGRADE} && \
		[[ -d ${PORTDIR} && -w ${PORTDIR} ]] ; then
		local ownership=$(get_ownership "${PORTDIR}")
		if [[ -n ${ownership} ]] ; then
			einfo "Adjusting PORTDIR permissions for usersync"
			find "${PORTDIR}" -path "${distdir%/}" -prune -o \
				! \( -user "${ownership%:*}" -a -group "${ownership#*:}" \) \
				-exec chown "${ownership}" {} +
		fi
	fi

	# Do this last, since it could take a long time if there
	# are lots of live sources, and the user may be tempted
	# to kill emerge while it is running.
	if ${USERPRIV_UPGRADE} && \
		[[ -d ${distdir} && -w ${distdir} ]] ; then
		local ownership=$(get_ownership "${distdir}")
		if [[ ${ownership#*:} == portage ]] ; then
			einfo "Adjusting DISTDIR permissions for userpriv"
			find "${distdir}" -mindepth 1 -maxdepth 1 -type d -uid 0 \
				-exec chown -R portage:portage {} +
		fi
	fi
}
