# Build fingerprint
ifneq ($(BUILD_FINGERPRINT),)
ADDITIONAL_BUILD_PROPERTIES += \
    ro.build.fingerprint=$(BUILD_FINGERPRINT)
endif

# LineageOS System Version
ADDITIONAL_BUILD_PROPERTIES += \
    ro.palladium.version=$(PALLADIUM_VERSION) \
    ro.palladium.releasetype=$(PALLADIUM_BUILDTYPE) \
    ro.palladium.build.version=$(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR) \
    ro.modversion=$(PALLADIUM_VERSION) 

# Palladium Platform Display Version
ADDITIONAL_BUILD_PROPERTIES += \
    ro.palladium.display.version=$(PALLADIUM_DISPLAY_VERSION)
