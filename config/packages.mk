# VoltageOS packages
PRODUCT_PACKAGES += \
    SimpleDeviceConfig \
    Canvas \
    Covers \
    Etar \
    ThemePicker \
    ThemesStub \
    Jellyfish \
    LogViewer \
    Gramophone \
    VoltageCrimson \
    GameSpace \
    VoltageSetupWizard \
    Seedvault \
    Datura \
    ExactCalculator \
    LMOFreeform \
    LMOFreeformSidebar \
    OmniJaws \
    AppCompatConfig \
    AppDataBackup

PRODUCT_PACKAGES += \
    Updater


# BtHelper
PRODUCT_PACKAGES += \
    BtHelper

# Extra tools in Voltage
PRODUCT_PACKAGES += \
    awk \
    bzip2 \
    curl \
    getcap \
    libsepol \
    setcap \

# Filesystems tools
PRODUCT_PACKAGES += \
    fsck.exfat \
    mke2fs \
    mkfs.exfat

# VoltageOS UDFPS animations
ifeq ($(EXTRA_UDFPS_ANIMATIONS),true)
PRODUCT_PACKAGES += \
    UdfpsIcons \
    UdfpsAnimations
endif
