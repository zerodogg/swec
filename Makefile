# swec makefile

VERSION=$(shell ./swec --version|perl -pi -e 's/^\D+//; chomp')

ifndef prefix
# This little trick ensures that make install will succeed both for a local
# user and for root. It will also succeed for distro installs as long as
# prefix is set by the builder.
prefix=$(shell perl -e 'if($$< == 0 or $$> == 0) { print "/usr" } else { print "$$ENV{HOME}/.local"}')
endif

BINDIR ?= $(prefix)/bin
DATADIR ?= $(prefix)/share

# Install swec
install:
	mkdir -p "$(BINDIR)"
	cp swec "$(BINDIR)"
	chmod 755 "$(BINDIR)/swec"
	[  -e swec.1 ] && mkdir -p "$(DATADIR)/man/man1" && cp swec.1 "$(DATADIR)/man/man1" || true
# Uninstall an installed swec
uninstall:
	rm -f "$(BINDIR)/swec"
	rm -f "$(DATADIR)/man/man1/swec.1"
# Clean up the tree
clean:
	rm -f `find|egrep '~$$'`
	rm -f swec-*.tar.bz2
	rm -rf swec-$(VERSION)
	rm -f swec.1
# Verify syntax
test:
	@perl -c swec
	@./swec --validate default.sdf
# Create a manpage from the POD
man:
	pod2man --name "Simple Web Error Checker" --center "" --release "swec $(VERSION)" ./swec ./swec.1
# Create the tarball
distrib: clean test man
	mkdir -p swec-$(VERSION)
	cp -r ./`ls|grep -v swec-$(VERSION)` ./swec-$(VERSION)
	rm -rf `find swec-$(VERSION) -name \\.git`
	tar -jcvf swec-$(VERSION).tar.bz2 ./swec-$(VERSION)
	rm -rf swec-$(VERSION)
