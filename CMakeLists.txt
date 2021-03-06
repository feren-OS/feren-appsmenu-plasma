cmake_minimum_required(VERSION 3.0)

project(plasma-desktop)

set(PROJECT_VERSION "5.21.00")
set(PROJECT_VERSION_MAJOR 5)

set(QT_MIN_VERSION "5.15.0")
set(KF5_MIN_VERSION "5.78")
set(ACCOUNTSQT_DEP_VERSION "1.13")

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(ECM ${KF5_MIN_VERSION} REQUIRED NO_MODULE)
set(CMAKE_MODULE_PATH ${ECM_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules)

include(KDEInstallDirs)
include(KDECMakeSettings)
include(KDEFrameworkCompilerSettings NO_POLICY_SCOPE)
include(ECMInstallIcons)
include(ECMMarkAsTest)
include(ECMMarkNonGuiExecutable)
include(ECMOptionalAddSubdirectory)
include(ECMQtDeclareLoggingCategory)
include(FeatureSummary)
include(CheckIncludeFiles)
include(KDEClangFormat)

find_package(Qt5 ${QT_MIN_VERSION} CONFIG REQUIRED COMPONENTS
    Quick
    QuickWidgets
    DBus
    Widgets
    X11Extras
    Svg
    Concurrent
)

find_package(KF5 ${KF5_MIN_VERSION} REQUIRED COMPONENTS
    Auth
    Plasma
    PlasmaQuick
    DocTools
    I18n
    KCMUtils
    NewStuff
    NewStuffQuick
    KDELibs4Support
    Notifications
    NotifyConfig
    Attica
    Runner
    GlobalAccel
    Declarative
    DBusAddons
    Activities
    ActivitiesStats
    Config
    Wallet
    WidgetsAddons
)

find_package(KF5Kirigami2 ${KF5_MIN_VERSION} CONFIG)
set_package_properties(KF5Kirigami2 PROPERTIES
    DESCRIPTION "A QtQuick based components set"
    PURPOSE "Required at runtime by many KCMs"
    TYPE RUNTIME
)

find_package(KF5QQC2DesktopStyle ${KF5_MIN_VERSION} CONFIG)
set_package_properties(KF5QQC2DesktopStyle PROPERTIES
    DESCRIPTION "QtQuickControls 2 style that uses QWidget's QStyle for painting"
    PURPOSE "Required at runtime by many KCMs"
    TYPE RUNTIME
)

find_package(LibKWorkspace ${PROJECT_VERSION} CONFIG REQUIRED)
find_package(LibNotificationManager ${PROJECT_VERSION} CONFIG REQUIRED)
find_package(LibTaskManager ${PROJECT_VERSION} CONFIG REQUIRED)
find_package(LibColorCorrect ${PROJECT_VERSION} CONFIG REQUIRED)
find_package(KWinDBusInterface CONFIG REQUIRED)
find_package(ScreenSaverDBusInterface CONFIG REQUIRED)
find_package(KRunnerAppDBusInterface CONFIG REQUIRED)
find_package(KSMServerDBusInterface CONFIG REQUIRED)
find_package(KF5ItemModels CONFIG REQUIRED)
find_package(KSysGuard CONFIG REQUIRED)
find_package(KDED CONFIG REQUIRED)

find_package(KF5Baloo ${KF5_MIN_VERSION})
set_package_properties(KF5Baloo PROPERTIES DESCRIPTION "File Searching"
                       TYPE RECOMMENDED
                       PURPOSE "Needed to build the File Search KCM"
                      )

find_package(X11)
set_package_properties(X11 PROPERTIES DESCRIPTION "X11 libraries"
                        URL "https://www.x.org"
                        TYPE REQUIRED
                        PURPOSE "Required for building the X11 based workspace"
                      )
if(X11_FOUND)
  set(HAVE_X11 1)
endif()

find_package(UDev)
set_package_properties(UDev PROPERTIES DESCRIPTION "UDev library"
                        URL "https://www.freedesktop.org/wiki/Software/systemd/"
                        TYPE OPTIONAL
                        PURPOSE "Required for device discovery in keyboard daemon"
                      )

find_package(XCB
    REQUIRED COMPONENTS
        XCB SHM IMAGE
    OPTIONAL_COMPONENTS
        XKB XINPUT
)

set_package_properties(XCB PROPERTIES TYPE REQUIRED)
add_feature_info("XCB-XKB" XCB_XKB_FOUND "Required for building kcm/keyboard")
add_feature_info("libxft" X11_Xft_FOUND "X FreeType interface library required for font installation")

find_package(Evdev)
set_package_properties(Evdev PROPERTIES TYPE OPTIONAL)
add_feature_info("Evdev" EVDEV_FOUND "Evdev driver headers needed for mouse KCM")

find_package(Synaptics)
set_package_properties(Synaptics PROPERTIES TYPE OPTIONAL)
add_feature_info("Synaptics" SYNAPTICS_FOUND "Synaptics libraries needed for touchpad KCM")

find_package(XorgServer)
set_package_properties(XorgServer PROPERTIES TYPE OPTIONAL)
add_feature_info("XorgServer" XORGSERVER_FOUND "XServer header needed for touchpad KCM (X11 backend)")

find_package(XorgLibinput)
set_package_properties(XorgLibinput PROPERTIES TYPE OPTIONAL)
add_feature_info("XorgLibinput" XORGLIBINPUT_FOUND "Libinput driver headers needed for mouse and touchpad KCM")

if(XORGLIBINPUT_FOUND)
  set(HAVE_XORGLIBINPUT 1)
endif()

include(ConfigureChecks.cmake)

find_package(PackageKitQt5)
set_package_properties(PackageKitQt5
        PROPERTIES DESCRIPTION "Software Manager integration"
        TYPE OPTIONAL
        PURPOSE "Used in the KRunner plugin installer"
        )
if(PackageKitQt5_FOUND)
    set(HAVE_PACKAGEKIT TRUE)
endif()

find_package(GLIB2)
set_package_properties(GLIB2
        PROPERTIES TYPE OPTIONAL
        PURPOSE "Required for building kimpanel"
        )

# For kimpanel
pkg_check_modules(IBUS "ibus-1.0>=1.5.0" IMPORTED_TARGET)
pkg_check_modules(GOBJECT gobject-2.0 IMPORTED_TARGET)
pkg_check_modules(SCIM scim IMPORTED_TARGET)

include_directories("${CMAKE_CURRENT_BINARY_DIR}")

configure_file(config-workspace.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/config-workspace.h)
configure_file(config-unix.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/config-unix.h )
configure_file(config-X11.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/config-X11.h)
configure_file(config-runtime.h.cmake ${CMAKE_CURRENT_BINARY_DIR}/config-runtime.h)

plasma_install_package(desktoppackage org.kde.plasma.desktop shells shell)

add_definitions(-DQT_NO_URL_CAST_FROM_STRING)

add_subdirectory(applets)

# add clang-format target for all our real source files
file(GLOB_RECURSE ALL_CLANG_FORMAT_SOURCE_FILES *.cpp *.h)
kde_clang_format(${ALL_CLANG_FORMAT_SOURCE_FILES})

feature_summary(WHAT ALL INCLUDE_QUIET_PACKAGES FATAL_ON_MISSING_REQUIRED_PACKAGES)
