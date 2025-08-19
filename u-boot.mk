######################################################################
#         2025 ARM64 Ubuntu/Debian Makefile - DO NOT EDIT            #
# Written by: Wig Cheng  <onlywig@gmail.com>                         #
######################################################################

include common.mk

all: build

clean:
	if test -d "$(UBOOT_SRC)/uboot-imx" ; then $(MAKE) ARCH=arm64 CROSS_COMPILE=${CC} -C $(UBOOT_DIR)/uboot-imx clean ; fi
	rm -f $(UBOOT_BIN)
	rm -rf $(wildcard $(UBOOT_DIR))

distclean: clean
	rm -rf $(wildcard $(UBOOT_DIR/uboot-imx))

build:
ifeq ($(PLATFORM),wafer-imx8mp)
	$(eval UBOOT_COMMIT := d5eaff674f1fbee3e13536218d8e6044bc27e818)
	$(eval UBOOT_ARCHIVE := https://github.com/QNAP-android-internal/uboot-imx/archive/$(UBOOT_COMMIT).tar.gz)
	$(eval UBOOT_DEFCONFIG := imx8mp_b643_ppc_defconfig)
	$(eval ATF_OPTION := imx8mp-b643-ppc)
else ifeq ($(PLATFORM),frdm-imx93)
	$(eval UBOOT_COMMIT := 40c8a907141d32b28895c69b8e0a8ff95313bda4)
	$(eval UBOOT_ARCHIVE := https://github.com/QNAP-android-internal/uboot-imx/archive/$(UBOOT_COMMIT).tar.gz)
	$(eval UBOOT_DEFCONFIG := edm-imx6_spl_defconfig)
endif

	mkdir -p $(UBOOT_DIR)
	if [ ! -f $(UBOOT_DIR)/uboot-imx/Makefile ] ; then \
		curl -L $(UBOOT_ARCHIVE) | tar xz && \
		mv uboot-imx-* $(UBOOT_DIR)/uboot-imx ; \
	fi

	$(MAKE) ARCH=arm CROSS_COMPILE=${CC} -C $(UBOOT_DIR)/uboot-imx $(UBOOT_DEFCONFIG)
	$(MAKE) ARCH=arm CROSS_COMPILE=${CC} -C $(UBOOT_DIR)/uboot-imx -j$(CPUS) all

	cd $(UBOOT_DIR)/uboot-imx; yes | ARCH=$(ARCH) CROSS_COMPILE=$(CC) ./install_uboot_imx8.sh -b $(ATF_OPTION).dtb -d /dev/null > /dev/null; cd -

u-boot: $(UBOOT_BIN)


.PHONY: build
