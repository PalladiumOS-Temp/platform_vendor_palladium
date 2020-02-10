# Copyright (C) 2021 The Palladium OS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ANDROID_VERSION := 11.0
PALLADIUMVERSION := v1.0

PALLADIUM_BUILDTYPE ?= UNOFFICIAL
PALLADIUM_BUILD_DATE := $(shell date +%Y%m%d)
TARGET_PRODUCT_SHORT := $(subst palladium_,,$(PALLADIUM_BUILD))

# OFFICIAL_DEVICES
ifeq ($(PALLADIUM_BUILDTYPE), OFFICIAL)
  LIST = $(shell cat vendor/palladium/palladium.devices)
    ifeq ($(filter $(PALLADIUM_BUILD), $(LIST)), $(PALLADIUM_BUILD))
      IS_OFFICIAL=true
      PALLADIUM_BUILDTYPE := OFFICIAL
    endif
    ifneq ($(IS_OFFICIAL), true)
      PALLADIUM_BUILDTYPE := UNOFFICIAL
      $(error Device is not official "$(PALLADIUM_BUILD)")
    endif
endif

# MAIN
PALLADIUM_VERSION := PalladiumOS-$(PALLADIUMVERSION)-$(PALLADIUM_BUILD)-$(PALLADIUM_BUILD_DATE)-$(PALLADIUM_BUILDTYPE)

PALLADIUM_MOD_VERSION :=$(ANDROID_VERSION)-$(PALLADIUMVERSION)

PALLADIUM_DISPLAY_VERSION := PalladiumOS-$(PALLADIUMVERSION)-$(PALLADIUM_BUILDTYPE)

PALLADIUM_DISPLAY_BUILDTYPE := $(PALLADIUM_BUILDTYPE)

PALLADIUM_FINGERPRINT := PalladiumOS/$(PALLADIUM_MOD_VERSION)/$(TARGET_PRODUCT_SHORT)/$(shell date -u +%H%M)