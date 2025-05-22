######################################################################
#         2025 ARM64 Ubuntu/Debian Makefile - DO NOT EDIT          #
# Written by: Wig Cheng  <onlywig@gmail.com>                       #
######################################################################

BUILD_STEPS := rootfs

all: build

pre-rootfs:

define BUILD_STEPS_TEMPLATE
build-$(1): pre-$(1)
	$$(MAKE) -f $(1).mk build
clean-$(1):
	$$(MAKE) -f $(1).mk clean
distclean-$(1):
	$$(MAKE) -f $(1).mk distclean
.PHONY: pre-$(1) build-$(1) clean-$(1) distclean-$(1)
endef

$(foreach step,$(BUILD_STEPS),$(eval $(call BUILD_STEPS_TEMPLATE,$(step))))

build: $(addprefix build-,$(BUILD_STEPS))

clean: $(addprefix clean-,$(BUILD_STEPS))

distclean: $(addprefix distclean-,$(BUILD_STEPS))

rootfs: build-rootfs

.PHONY: all build clean distclean rootfs
