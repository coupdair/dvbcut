# makefile.in - top-level makefile template for Linux/Unix
# Copyright (c) 2008 - 2011 Michael Riepe
#  
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#  
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#  
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

#@(#) $Id$

srcdir = .
top_srcdir = .

prefix = /usr/local
exec_prefix = ${prefix}
bindir = ${exec_prefix}/bin
datadir = ${datarootdir}
datarootdir = ${prefix}/share
mandir = ${datarootdir}/man
man1dir = $(mandir)/man1
pkgdatadir = $(datarootdir)/dvbcut

installdirs = $(DESTDIR)$(man1dir) \
	$(DESTDIR)$(pkgdatadir)/icons \
	$(DESTDIR)/usr/share/applications \
	$(DESTDIR)/usr/share/mime/packages

INSTALL = /usr/bin/install -c
INSTALL_DATA = ${INSTALL} -m 644
INSTALL_PROGRAM = ${INSTALL}

all check dep distfiles install mostlyclean clean distclean maintainer-clean::
	$(MAKE) -C src $@
	$(MAKE) $@-local

all-local:
check-local:
dep-local:
install-local: $(installdirs) dvbcut.1 dvbcut.desktop dvbcut.xml
	$(INSTALL_DATA) dvbcut.1 $(DESTDIR)$(man1dir)/dvbcut.1
	$(INSTALL_DATA) dvbcut.desktop $(DESTDIR)/usr/share/applications
	$(INSTALL_DATA) dvbcut.svg $(DESTDIR)$(pkgdatadir)/icons
	$(INSTALL_DATA) dvbcut.xml $(DESTDIR)/usr/share/mime/packages
	-update-mime-database $(DESTDIR)/usr/share/mime

$(installdirs):
	$(SHELL) $(top_srcdir)/mkinstalldirs $@

mostlyclean-local:
clean-local: mostlyclean-local
	rm -rf ffmpeg
	rm -f config.log
distclean-local: clean-local
	rm -f makefile config.cache config.status
maintainer-clean-local: distclean-local
	rm -f configure

distfiles-local: configure
configure: configure.in
	autoconf

VERSION := $(shell cat VERSION)
DISTFILES := $(shell cat DISTFILES)

src/version.h: $(DISTFILES)
	$(SHELL) ./setversion.sh $(DISTFILES)

distdir = dvbcut-$(VERSION)
dist: distfiles ./stamp-dist
./stamp-dist: $(DISTFILES)
	rm -rf $(distdir)
	mkdir $(distdir)
	files="$(DISTFILES)"; for file in $$files; do \
		d=`dirname $$file`; \
		test -d $(distdir)/$$d || mkdir -p $(distdir)/$$d || exit 1; \
		ln $$file $(distdir)/$$file || exit 1; \
	done
	cd $(distdir) && $(SHELL) ./setversion.sh $(DISTFILES)
	cd $(distdir) && \
		find . -type f ! -name MANIFEST -exec wc -c {} \; | \
		sort -k 2 >MANIFEST
	-@rm -f $(distdir).tar.gz.bak dvbcut.tar.gz
	-@mv -f $(distdir).tar.gz $(distdir).tar.gz.bak
	tar cvohfz $(distdir).tar.gz --numeric-owner --owner=0 --group=0 $(distdir)
	ln -s $(distdir).tar.gz dvbcut.tar.gz
	rm -f stamp-dist && echo timestamp > stamp-dist

CONFIGURE_ARGS = 

check-dist:
	cd $(distdir) && CONFIG_SITE=/no/config.site ./configure $(CONFIGURE_ARGS)
	$(MAKE) -C $(distdir)
	$(MAKE) -C $(distdir) check
	$(MAKE) -C $(distdir) dist
	diff $(distdir)/MANIFEST $(distdir)/$(distdir)/MANIFEST

bindist: all
	dir=$(distdir)-`arch`; \
	rm -rf $$dir; \
	make install DESTDIR=`pwd`/$$dir && \
	cd $$dir && \
	tar cvofz ../$$dir.tar.gz --numeric-owner --owner=0 --group=0 *

