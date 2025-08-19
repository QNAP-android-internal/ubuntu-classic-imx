######################################################################
#         2025 ARM64 Ubuntu/Debian Makefile - DO NOT EDIT            #
# Written by: Wig Cheng  <onlywig@gmail.com>                         #
######################################################################

include common.mk

DEFAULT_IMAGE := ubuntu.img

all: build

clean:
	rm -rf $(OUTPUT_DIR)/$(DEFAULT_IMAGE)
distclean: clean

build-image:
ifeq ($(PLATFORM),wafer-imx8mp)
	$(eval TARGET := wafer-imx8mp)
else ifeq ($(PLATFORM),frdm-imx93)
	$(eval TARGET := frdm-imx93)
endif

	@echo "image generating..."
	sudo ./gen_image.sh $(TARGET)
	@mv test.img $(OUTPUT_DIR)/$(DEFAULT_IMAGE)

build: build-image

.PHONY: build-image build
