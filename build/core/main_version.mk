# Build fingerprint
ifneq ($(BUILD_FINGERPRINT),)
ADDITIONAL_BUILD_PROPERTIES += \
    ro.build.fingerprint=$(BUILD_FINGERPRINT)
endif

# Palladium-OS System Version
ADDITIONAL_BUILD_PROPERTIES += \
  ro.palladium.version=$(PALLADIUM_DISPLAY_VERSION) \
  ro.palladium.build.status=$(PALLADIUM_BUILDTYPE) \
  ro.modversion=$(PALLADIUM_MOD_VERSION) \
  ro.palladium.build.date=$(BUILD_DATE) \
  ro.palladium.buildtype=$(PALLADIUM_BUILDTYPE) \
  ro.palladium.fingerprint=$(PALLADIUM_FINGERPRINT) \
  ro.palladium.build.variant=$(PALLADIUM_BUILD_VARIANT) \
  ro.palladium.device=$(PALLADIUM_BUILD) \
  ro.palladium.build.version=$(PLATFORM_VERSION)
