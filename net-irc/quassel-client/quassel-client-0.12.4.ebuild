# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6

inherit cmake-utils eutils

EGIT_REPO_URI="git://git.quassel-irc.org/quassel"
[[ "${PV}" == "9999" ]] && inherit git-r3
MY_P=${P/-client}
# MY_PN=${PN/-client}

DESCRIPTION="Qt/KDE IRC client supporting a remote daemon for 24/7 connectivity (client only)"
HOMEPAGE="http://quassel-irc.org/"
[[ "${PV}" == "9999" ]] || SRC_URI="http://quassel-irc.org/pub/${MY_P}.tar.bz2"

LICENSE="GPL-3"
KEYWORDS="~amd64 ~x86"
SLOT="0"
IUSE="ayatana crypt dbus debug kde phonon qt5 snorenotify +ssl webkit"

GUI_RDEPEND="
	qt5? (
		dev-qt/qtgui:5
		dev-qt/qtwidgets:5
		dbus? (
			>=dev-libs/libdbusmenu-qt-0.9.3_pre20140619[qt5]
			dev-qt/qtdbus:5
		)
		kde? (
			kde-frameworks/kconfigwidgets:5
			kde-frameworks/kcoreaddons:5
			kde-frameworks/knotifications:5
			kde-frameworks/knotifyconfig:5
			kde-frameworks/ktextwidgets:5
			kde-frameworks/kwidgetsaddons:5
			kde-frameworks/kxmlgui:5
			kde-frameworks/sonnet:5
		)
		phonon? ( media-libs/phonon[qt5] )
		snorenotify? ( >=x11-libs/snorenotify-0.7.0 )
		webkit? ( dev-qt/qtwebkit:5 )
	)
	!qt5? (
		dev-qt/qtgui:4
		ayatana? ( dev-libs/libindicate-qt )
		dbus? (
			>=dev-libs/libdbusmenu-qt-0.9.3_pre20140619[qt4(+)]
			dev-qt/qtdbus:4
			kde? (
				kde-base/kdelibs:4
				ayatana? ( kde-misc/plasma-widget-message-indicator )
			)
		)
		phonon? ( || ( media-libs/phonon[qt4] dev-qt/qtphonon:4 ) )
		webkit? ( dev-qt/qtwebkit:4 )
	)
"

RDEPEND="
	~net-irc/quassel-common-${PV}
	sys-libs/zlib
	qt5? (
		dev-qt/qtcore:5
		dev-qt/qtnetwork:5[ssl?]
	)
	!qt5? ( dev-qt/qtcore:4[ssl?] )
	${GUI_RDEPEND}
"
DEPEND="${RDEPEND}
	qt5? (
		dev-qt/linguist-tools:5
		kde-frameworks/extra-cmake-modules
	)
"

REQUIRED_USE="
	kde? ( phonon )
"

S="${WORKDIR}/${MY_P}"

src_configure() {
	local mycmakeargs=(
		-DCMAKE_SKIP_RPATH=ON # added in Sabayon's split ebuild
		$(cmake-utils_use_find_package ayatana IndicateQt)
		$(cmake-utils_use_find_package crypt QCA2)
		$(cmake-utils_use_find_package crypt QCA2-QT5)
		$(cmake-utils_use_find_package dbus dbusmenu-qt)
		$(cmake-utils_use_find_package dbus dbusmenu-qt5)
		-DWITH_KDE=$(usex kde)
		"-DWITH_OXYGEN=OFF"
		"-DWANT_MONO=OFF"
		$(cmake-utils_use_find_package phonon Phonon)
		$(cmake-utils_use_find_package phonon Phonon4Qt5)
		-DUSE_QT5=$(usex qt5)
		"-DWANT_CORE=OFF"
		$(cmake-utils_use_find_package snorenotify LibsnoreQt5)
		-DWITH_WEBKIT=$(usex webkit)
		"-DWANT_QTCLIENT=ON"
		-DEMBED_DATA=OFF
		-DCMAKE_SKIP_RPATH=ON
	)

	# Something broke upstream detection since Qt 5.5
	if use ssl ; then
		mycmakeargs+=("-DHAVE_SSL=TRUE")
	fi

	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install

	rm -r "${ED}"usr/share/quassel/{networks.ini,scripts,stylesheets,translations} || die
	rmdir "${ED}"usr/share/quassel || die # should be empty
	rm -r "${ED}"usr/share/pixmaps || die
	rm -r "${ED}"usr/share/icons || die

	insinto /usr/share/applications
	doins data/quasselclient.desktop
}

pkg_postinst() {
	elog "To make use of quasselclient, install server, too."
	elog "It is provided by net-irc/quassel-core and net-irc/quassel-core-bin."
}
