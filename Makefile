# swec makefile

VERSION=$(shell ./swec --version|perl -pi -e 's/^\D+//; chomp')

ifndef prefix
# This little trick ensures that make install will succeed both for a local
# user and for root. It will also succeed for distro installs as long as
# prefix is set by the builder.
prefix=$(shell perl -e 'if($$< == 0 or $$> == 0) { print "/usr" } else { print "$$ENV{HOME}/.local"}')

# Some additional magic here, what it does is set BINDIR to ~/bin IF we're not root
# AND ~/bin exists, if either of these checks fail, then it falls back to the standard
# $(prefix)/bin. This is also inside ifndef prefix, so if a prefix is supplied
# (ie. meaning this is a packaging), we won't run this at all
BINDIR ?= $(shell perl -e 'if(($$< > 0 && $$> > 0) and -e "$$ENV{HOME}/bin") { print "$$ENV{HOME}/bin";exit; } else { print "$(prefix)/bin"}')
endif

BINDIR ?= $(prefix)/bin
DATADIR ?= $(prefix)/share

# Install swec
install:
	mkdir -p "$(BINDIR)"
	cp swec "$(BINDIR)"
	chmod 755 "$(BINDIR)/swec"
	[  -e swec.1 ] && mkdir -p "$(DATADIR)/man/man1" && cp swec.1 "$(DATADIR)/man/man1" || true
localinstall:
	mkdir -p "$(BINDIR)"
	ln -sf $(shell pwd)/swec $(BINDIR)/
	[  -e swec.1 ] && mkdir -p "$(DATADIR)/man/man1" && ln -sf $(shell pwd)/swec.1 "$(DATADIR)/man/man1" || true
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
