CC ?= gcc
CFLAGS ?= -O3 -Wall -Wextra
PKG_CONFIG ?= pkg-config

DEPS = gtk+-3.0 gtk-layer-shell-0 cairo glib-2.0
CFLAGS += $(shell $(PKG_CONFIG) --cflags $(DEPS))
LIBS = $(shell $(PKG_CONFIG) --libs $(DEPS)) -lm

PREFIX ?= $(HOME)/.local
BINDIR ?= $(PREFIX)/bin

all: crosshair

crosshair: main.c
	$(CC) $(CFLAGS) $< $(LIBS) -o $@

install: crosshair
	install -Dm755 crosshair $(DESTDIR)$(BINDIR)/crosshair

clean:
	rm -f crosshair

.PHONY: all install clean
