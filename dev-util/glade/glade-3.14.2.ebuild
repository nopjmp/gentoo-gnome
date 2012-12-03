# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"
GCONF_DEBUG="yes"
GNOME2_LA_PUNT="yes"

inherit eutils gnome2 versionator

DESCRIPTION="A User Interface Designer"
HOMEPAGE="http://glade.gnome.org/"

LICENSE="GPL-2"
SLOT="3.10"
KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~mips ~ppc ~ppc64 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd"
IUSE="+introspection python"

RDEPEND="dev-libs/atk[introspection?]
	>=dev-libs/glib-2.32:2
	>=dev-libs/libxml2-2.4.0:2
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2[introspection?]
	>=x11-libs/gtk+-3.6:3[introspection?]
	x11-libs/pango[introspection?]
	introspection? ( >=dev-libs/gobject-introspection-0.10.1 )
	python? ( >=dev-python/pygobject-2.90.4:3 )
"
DEPEND="${RDEPEND}
	app-text/docbook-xml-dtd:4.1.2
	app-text/yelp-tools
	>=dev-util/gtk-doc-am-1.13
	>=dev-util/intltool-0.41.0
	>=sys-devel/gettext-0.17
	virtual/pkgconfig
"
# eautoreconf requires:
#	dev-libs/gobject-introspection-common
#	gnome-base/gnome-common

src_prepare() {
	# To avoid file collison with other slots, rename help module.
	# Prevent the UI from loading glade:3's gladeui devhelp documentation.
	epatch "${FILESDIR}/${PN}-3.14.1-doc-version.patch"

	gnome2_src_prepare
}

src_configure() {
	DOCS="AUTHORS ChangeLog NEWS README TODO"
	G2CONF="${G2CONF}
		--disable-static
		--enable-libtool-lock
		$(use_enable introspection)
		$(use_enable python)"
	gnome2_src_configure
}

src_install() {
	# modify Name in .desktop file to avoid confusion with other slots
	sed -e 's:^\(Name.*=Glade\):\1 '$(get_version_component_range 1-2): \
		-i data/glade.desktop || die "sed of data/glade.desktop failed"
	# modify name in .devhelp2 file to avoid shadowing with glade:3 docs
	sed -e 's:name="gladeui":name="gladeui-2":' \
		-i doc/html/gladeui.devhelp2 || die "sed of gladeui.devhelp2 failed"
	gnome2_src_install
}

pkg_postinst() {
	gnome2_pkg_postinst
	if ! has_version dev-util/devhelp ; then
		elog "You may want to install dev-util/devhelp for integration API"
		elog "documentation support."
	fi
}