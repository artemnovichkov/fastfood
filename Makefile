SHELL = /bin/bash

REPODIR = $(shell pwd)
BUILDDIR = $(REPODIR)/.build
RELEASEBUILDDIR = $(BUILDDIR)/release
TEMPPRODUCTDIR = $(BUILDDIR)/_PRODUCT
PRODUCTDIR = $(RELEASEBUILDDIR)/_PRODUCT

.DEFAULT_GOAL = all

.PHONY: all
all: build

.PHONY: build
build:
	@swift build \
		-c release \
		--disable-sandbox \
		--build-path "$(BUILDDIR)"
	@rm -rf "$(PRODUCTDIR)"
	@rm -rf "$(TEMPPRODUCTDIR)"
	@mkdir -p "$(TEMPPRODUCTDIR)"
	@mkdir -p "$(TEMPPRODUCTDIR)/include/fastfood"
	@cp -a "$(RELEASEBUILDDIR)/." "$(TEMPPRODUCTDIR)/include/fastfood"
	@cp -a "$(TEMPPRODUCTDIR)/." "$(PRODUCTDIR)"
	@rm -rf "$(TEMPPRODUCTDIR)"
	@mkdir -p "$(PRODUCTDIR)/bin"
	@rm -rf $(PRODUCTDIR)/include/fastfood/*.build
	@rm -rf $(PRODUCTDIR)/include/fastfood/*.product
	@rm -rf $(PRODUCTDIR)/include/fastfood/ModuleCache
	@rm -f "$(PRODUCTDIR)/include/fastfood/fastfood.swiftdoc"
	@rm -f "$(PRODUCTDIR)/include/fastfood/fastfood.swiftmodule"
	@mv "$(PRODUCTDIR)/include/fastfood/fastfood" "$(PRODUCTDIR)/bin"
	@rm -f "$(RELEASEBUILDDIR)/fastfood"
	@ln -s "$(PRODUCTDIR)/bin/fastfood" "$(RELEASEBUILDDIR)/fastfood"
	@cp "$(REPODIR)/LICENSE" "$(PRODUCTDIR)/LICENSE"

.PHONY: package
package:
	rm -f "$(PRODUCTDIR)/fastfood.zip"
	cd $(PRODUCTDIR) && zip -r ./fastfood.zip ./
	echo "ZIP created at: $(PRODUCTDIR)/fastfood.zip"

.PHONY: clean
clean:
	@rm -rf "$(BUILDDIR)"