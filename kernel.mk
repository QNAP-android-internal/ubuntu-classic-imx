######################################################################
#         2025 ARM64 Ubuntu/Debian Makefile - DO NOT EDIT            #
# Written by: Wig Cheng  <onlywig@gmail.com>                         #
######################################################################

include common.mk

ifeq ($(PLATFORM),wafer-imx8mp)
KERNEL_DEFCONFIG := iei_imx8_defconfig
$(eval KERNEL_COMMIT  := a0bdfb8d5b17b51ee828ae24adf7abb22e2a465a)
$(eval KERNEL_ARCHIVE := https://github.com/QNAP-android-internal/kernel_imx/archive/$(KERNEL_COMMIT).tar.gz)
$(eval ARCH := arm64)
else ifeq ($(PLATFORM),frdm-imx93)
KERNEL_DEFCONFIG := iei_imx8_defconfig
$(eval KERNEL_COMMIT  := af26215f8295919821a38d2288df4c76e9ffa216)
$(eval KERNEL_ARCHIVE := https://github.com/QNAP-android-internal/kernel_imx/archive/$(KERNEL_COMMIT).tar.gz)
$(eval ARCH := arm64)
endif

all: build

clean:
	if test -d "$(KERNEL_SRC)/kernel_imx" ; then $(MAKE) ARCH=${ARCH} CROSS_COMPILE=${CC} -C $(KERNEL_DIR)/kernel_imx clean ; fi
	rm -f $(KERNEL_BIN)
	rm -rf $(wildcard $(KERNEL_DIR))

distclean: clean
	rm -rf $(wildcard $(KERNEL_DIR/kernel_imx))

build: src
	$(MAKE) ARCH=${ARCH} CROSS_COMPILE=${CC} -C $(KERNEL_DIR)/kernel_imx $(KERNEL_DEFCONFIG)
	$(MAKE) ARCH=${ARCH} CROSS_COMPILE=${CC} -C $(KERNEL_DIR)/kernel_imx -j$(CPUS) all
	$(MAKE) ARCH=${ARCH} CROSS_COMPILE=${CC} -C $(KERNEL_DIR)/kernel_imx -j$(CPUS) dtbs
	$(MAKE) ARCH=${ARCH} CROSS_COMPILE=${CC} -C $(KERNEL_DIR)/kernel_imx -j$(CPUS) modules
	$(MAKE) ARCH=${ARCH} CROSS_COMPILE=${CC} -C $(KERNEL_DIR)/kernel_imx -j$(CPUS) modules_install INSTALL_MOD_STRIP=1 INSTALL_MOD_PATH=$(KERNEL_DIR)/kernel_imx/modules/

src:
	mkdir -p $(KERNEL_DIR)
	if [ ! -f $(KERNEL_DIR)/kernel_imx/Makefile ] ; then \
		curl -L $(KERNEL_ARCHIVE) | tar xz && \
		mv kernel_imx* $(KERNEL_DIR)/kernel_imx ; \
	fi

.PHONY: build
