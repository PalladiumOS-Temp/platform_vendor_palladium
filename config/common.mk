# Allow vendor/extra to override any property by setting it first
$(call inherit-product-if-exists, vendor/extra/product.mk)

PRODUCT_BRAND ?= Palladium

PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0

ifeq ($(PRODUCT_GMS_CLIENTID_BASE),)
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.com.google.clientidbase=android-google
else
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.com.google.clientidbase=$(PRODUCT_GMS_CLIENTID_BASE)
endif

ifeq ($(TARGET_BUILD_VARIANT),eng)
# Disable ADB authentication
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += ro.adb.secure=0
else
# Enable ADB authentication
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += ro.adb.secure=1
endif

# Backup Tool
PRODUCT_COPY_FILES += \
    vendor/palladium/prebuilt/common/bin/backuptool.sh:install/bin/backuptool.sh \
    vendor/palladium/prebuilt/common/bin/backuptool.functions:install/bin/backuptool.functions \
    vendor/palladium/prebuilt/common/bin/50-lineage.sh:$(TARGET_COPY_OUT_SYSTEM)/addon.d/50-lineage.sh

ifneq ($(AB_OTA_PARTITIONS),)
PRODUCT_COPY_FILES += \
    vendor/palladium/prebuilt/common/bin/backuptool_ab.sh:$(TARGET_COPY_OUT_SYSTEM)/bin/backuptool_ab.sh \
    vendor/palladium/prebuilt/common/bin/backuptool_ab.functions:$(TARGET_COPY_OUT_SYSTEM)/bin/backuptool_ab.functions \
    vendor/palladium/prebuilt/common/bin/backuptool_postinstall.sh:$(TARGET_COPY_OUT_SYSTEM)/bin/backuptool_postinstall.sh
ifneq ($(TARGET_BUILD_VARIANT),user)
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.ota.allow_downgrade=true
endif
endif

# Backup Services whitelist
PRODUCT_COPY_FILES += \
    vendor/palladium/config/permissions/backup.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/sysconfig/backup.xml

# Copy all Palladium-specific init rc files
$(foreach f,$(wildcard vendor/palladium/prebuilt/common/etc/init/*.rc),\
	$(eval PRODUCT_COPY_FILES += $(f):$(TARGET_COPY_OUT_SYSTEM)/etc/init/$(notdir $f)))

# Copy over added mimetype supported in libcore.net.MimeUtils
PRODUCT_COPY_FILES += \
    vendor/palladium/prebuilt/common/lib/content-types.properties:$(TARGET_COPY_OUT_SYSTEM)/lib/content-types.properties

# Enable Android Beam on all targets
PRODUCT_COPY_FILES += \
    vendor/palladium/config/permissions/android.software.nfc.beam.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/android.software.nfc.beam.xml

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:$(TARGET_COPY_OUT_SYSTEM)/etc/permissions/android.software.sip.voip.xml

# Enable wireless Xbox 360 controller support
PRODUCT_COPY_FILES += \
    frameworks/base/data/keyboards/Vendor_045e_Product_028e.kl:$(TARGET_COPY_OUT_SYSTEM)/usr/keylayout/Vendor_045e_Product_0719.kl

# Enforce privapp-permissions whitelist
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.control_privapp_permissions=enforce

# Include AOSP audio files
include vendor/palladium/config/aosp_audio.mk

# Include Palladium audio files
include vendor/palladium/config/palladium_audio.mk

# TWRP
ifeq ($(WITH_TWRP),true)
include vendor/palladium/config/twrp.mk
endif

# Do not include art debug targets
PRODUCT_ART_TARGET_INCLUDE_DEBUG_BUILD := false

# Strip the local variable table and the local variable type table to reduce
# the size of the system image. This has no bearing on stack traces, but will
# leave less information available via JDWP.
PRODUCT_MINIMIZE_JAVA_DEBUG_INFO := true

# Disable vendor restrictions
PRODUCT_RESTRICT_VENDOR_FILES := false

# Bootanimation
PRODUCT_PACKAGES += \
    bootanimation.zip

# AOSP packages
PRODUCT_PACKAGES += \
    Terminal

# Palladium packages
PRODUCT_PACKAGES += \
    PalladiumParts \
    PalladiumSettingsProvider \
    PalladiumSetupWizard \
    Updater

# Themes
PRODUCT_PACKAGES += \
    PalladiumThemesStub \
    ThemePicker

# Extra tools in Palladium
PRODUCT_PACKAGES += \
    7z \
    awk \
    bash \
    bzip2 \
    curl \
    getcap \
    htop \
    lib7z \
    libsepol \
    nano \
    pigz \
    powertop \
    setcap \
    unrar \
    unzip \
    vim \
    wget \
    zip

# Filesystems tools
PRODUCT_PACKAGES += \
    fsck.exfat \
    fsck.ntfs \
    mke2fs \
    mkfs.exfat \
    mkfs.ntfs \
    mount.ntfs

# Openssh
PRODUCT_PACKAGES += \
    scp \
    sftp \
    ssh \
    sshd \
    sshd_config \
    ssh-keygen \
    start-ssh

# rsync
PRODUCT_PACKAGES += \
    rsync

# Storage manager
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    ro.storage_manager.enabled=true

# These packages are excluded from user builds
PRODUCT_PACKAGES_DEBUG += \
    procmem

# Root
PRODUCT_PACKAGES += \
    adb_root
ifneq ($(TARGET_BUILD_VARIANT),user)
ifeq ($(WITH_SU),true)
PRODUCT_PACKAGES += \
    su
endif
endif

# Dex preopt
PRODUCT_DEXPREOPT_SPEED_APPS += \
    SystemUI \
    TrebuchetQuickStep

PRODUCT_ENFORCE_RRO_EXCLUDED_OVERLAYS += vendor/palladium/overlay
DEVICE_PACKAGE_OVERLAYS += vendor/palladium/overlay/common

PRODUCT_VERSION_MAJOR = 11
PRODUCT_VERSION_MINOR = 0
PRODUCT_VERSION_MAINTENANCE := 0

ifeq ($(TARGET_VENDOR_SHOW_MAINTENANCE_VERSION),true)
    PALLADIUM_VERSION_MAINTENANCE := $(PRODUCT_VERSION_MAINTENANCE)
else
    PALLADIUM_VERSION_MAINTENANCE := 0
endif

# Set PALLADIUM_BUILDTYPE from the env RELEASE_TYPE, for jenkins compat

ifndef PALLADIUM_BUILDTYPE
    ifdef RELEASE_TYPE
        # Starting with "PALLADIUM_" is optional
        RELEASE_TYPE := $(shell echo $(RELEASE_TYPE) | sed -e 's|^PALLADIUM_||g')
        PALLADIUM_BUILDTYPE := $(RELEASE_TYPE)
    endif
endif

# Filter out random types, so it'll reset to UNOFFICIAL
ifeq ($(filter RELEASE NIGHTLY SNAPSHOT EXPERIMENTAL,$(PALLADIUM_BUILDTYPE)),)
    PALLADIUM_BUILDTYPE :=
endif

ifdef PALLADIUM_BUILDTYPE
    ifneq ($(PALLADIUM_BUILDTYPE), SNAPSHOT)
        ifdef PALLADIUM_EXTRAVERSION
            # Force build type to EXPERIMENTAL
            PALLADIUM_BUILDTYPE := EXPERIMENTAL
            # Remove leading dash from PALLADIUM_EXTRAVERSION
            PALLADIUM_EXTRAVERSION := $(shell echo $(PALLADIUM_EXTRAVERSION) | sed 's/-//')
            # Add leading dash to PALLADIUM_EXTRAVERSION
            PALLADIUM_EXTRAVERSION := -$(PALLADIUM_EXTRAVERSION)
        endif
    else
        ifndef PALLADIUM_EXTRAVERSION
            # Force build type to EXPERIMENTAL, SNAPSHOT mandates a tag
            PALLADIUM_BUILDTYPE := EXPERIMENTAL
        else
            # Remove leading dash from PALLADIUM_EXTRAVERSION
            PALLADIUM_EXTRAVERSION := $(shell echo $(PALLADIUM_EXTRAVERSION) | sed 's/-//')
            # Add leading dash to PALLADIUM_EXTRAVERSION
            PALLADIUM_EXTRAVERSION := -$(PALLADIUM_EXTRAVERSION)
        endif
    endif
else
    # If PALLADIUM_BUILDTYPE is not defined, set to UNOFFICIAL
    PALLADIUM_BUILDTYPE := UNOFFICIAL
    PALLADIUM_EXTRAVERSION :=
endif

ifeq ($(PALLADIUM_BUILDTYPE), UNOFFICIAL)
    ifneq ($(TARGET_UNOFFICIAL_BUILD_ID),)
        PALLADIUM_EXTRAVERSION := -$(TARGET_UNOFFICIAL_BUILD_ID)
    endif
endif

ifeq ($(PALLADIUM_BUILDTYPE), RELEASE)
    ifndef TARGET_VENDOR_RELEASE_BUILD_ID
        PALLADIUM_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(PRODUCT_VERSION_MAINTENANCE)$(PRODUCT_VERSION_DEVICE_SPECIFIC)-$(PALLADIUM_BUILD)
    else
        ifeq ($(TARGET_BUILD_VARIANT),user)
            ifeq ($(PALLADIUM_VERSION_MAINTENANCE),0)
                PALLADIUM_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(TARGET_VENDOR_RELEASE_BUILD_ID)-$(PALLADIUM_BUILD)
            else
                PALLADIUM_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(PALLADIUM_VERSION_MAINTENANCE)-$(TARGET_VENDOR_RELEASE_BUILD_ID)-$(PALLADIUM_BUILD)
            endif
        else
            PALLADIUM_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(PRODUCT_VERSION_MAINTENANCE)$(PRODUCT_VERSION_DEVICE_SPECIFIC)-$(PALLADIUM_BUILD)
        endif
    endif
else
    ifeq ($(PALLADIUM_VERSION_MAINTENANCE),0)
        ifeq ($(PALLADIUM_VERSION_APPEND_TIME_OF_DAY),true)
            PALLADIUM_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(shell date -u +%Y%m%d_%H%M%S)-$(PALLADIUM_BUILDTYPE)$(PALLADIUM_EXTRAVERSION)-$(PALLADIUM_BUILD)
        else
            PALLADIUM_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(shell date -u +%Y%m%d)-$(PALLADIUM_BUILDTYPE)$(PALLADIUM_EXTRAVERSION)-$(PALLADIUM_BUILD)
        endif
    else
        ifeq ($(PALLADIUM_VERSION_APPEND_TIME_OF_DAY),true)
            PALLADIUM_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(PALLADIUM_VERSION_MAINTENANCE)-$(shell date -u +%Y%m%d_%H%M%S)-$(PALLADIUM_BUILDTYPE)$(PALLADIUM_EXTRAVERSION)-$(PALLADIUM_BUILD)
        else
            PALLADIUM_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(PALLADIUM_VERSION_MAINTENANCE)-$(shell date -u +%Y%m%d)-$(PALLADIUM_BUILDTYPE)$(PALLADIUM_EXTRAVERSION)-$(PALLADIUM_BUILD)
        endif
    endif
endif

PRODUCT_EXTRA_RECOVERY_KEYS += \
    vendor/palladium/build/target/product/security/lineage

-include vendor/palladium-priv/keys/keys.mk

PALLADIUM_DISPLAY_VERSION := $(PALLADIUM_VERSION)

ifneq ($(PRODUCT_DEFAULT_DEV_CERTIFICATE),)
ifneq ($(PRODUCT_DEFAULT_DEV_CERTIFICATE),build/target/product/security/testkey)
    ifneq ($(PALLADIUM_BUILDTYPE), UNOFFICIAL)
        ifndef TARGET_VENDOR_RELEASE_BUILD_ID
            ifneq ($(PALLADIUM_EXTRAVERSION),)
                # Remove leading dash from PALLADIUM_EXTRAVERSION
                PALLADIUM_EXTRAVERSION := $(shell echo $(PALLADIUM_EXTRAVERSION) | sed 's/-//')
                TARGET_VENDOR_RELEASE_BUILD_ID := $(PALLADIUM_EXTRAVERSION)
            else
                TARGET_VENDOR_RELEASE_BUILD_ID := $(shell date -u +%Y%m%d)
            endif
        else
            TARGET_VENDOR_RELEASE_BUILD_ID := $(TARGET_VENDOR_RELEASE_BUILD_ID)
        endif
        ifeq ($(PALLADIUM_VERSION_MAINTENANCE),0)
            PALLADIUM_DISPLAY_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(TARGET_VENDOR_RELEASE_BUILD_ID)-$(PALLADIUM_BUILD)
        else
            PALLADIUM_DISPLAY_VERSION := $(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR).$(PALLADIUM_VERSION_MAINTENANCE)-$(TARGET_VENDOR_RELEASE_BUILD_ID)-$(PALLADIUM_BUILD)
        endif
    endif
endif
endif

-include $(WORKSPACE)/build_env/image-auto-bits.mk
-include vendor/palladium/config/partner_gms.mk
