######################################################################
#         2025 ARM64    Ubuntu/Debian Makefile - DO NOT EDIT         #
# Written by: Wig Cheng  <onlywig@gmail.com>                         #
######################################################################

ROOTFS_PACK := rootfs.tgz

DISTRO := noble
LANG := en

ifeq ($(PLATFORM),wafer-imx8mp)
    TARGET := wafer-imx8mp
else ifeq ($(PLATFORM),frdm-imx93)
    TARGET := frdm-imx93
else
    TARGET := unknown_target
    $(warning PLATFORM is not wafer-imx8mp or frdm-imx93, TARGET set to $(TARGET))
endif

all: build

clean:
	rm -rf output/$(ROOTFS_PACK)
distclean: clean

build-rootfs: src
	@echo "PLATFORM: $(PLATFORM)"
	@echo "TARGET: $(TARGET)"
	@echo "DISTRO: $(DISTRO)"
	@echo "LANG: $(LANG)"
	@echo "build rootfs..."
	./gen_rootfs.sh $(TARGET) $(DISTRO) $(LANG)
	@mv $(ROOTFS_PACK) output/$(ROOTFS_PACK)

build: build-rootfs

src:
	if [ ! -d output ] ; then \
		mkdir -p output; \
	fi

.PHONY: all clean distclean build-rootfs build src
