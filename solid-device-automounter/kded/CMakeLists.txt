set(kded_device_automounter_SRCS DeviceAutomounter.cpp)

kconfig_add_kcfg_files(kded_device_automounter_SRCS ${CMAKE_CURRENT_SOURCE_DIR}/../lib/AutomounterSettingsBase.kcfgc)

add_library(kded_device_automounter MODULE ${device_automounter_lib_SRCS} ${kded_device_automounter_SRCS})
set_target_properties(kded_device_automounter PROPERTIES OUTPUT_NAME device_automounter)
kcoreaddons_desktop_to_json(kded_device_automounter device_automounter.desktop)
target_link_libraries(kded_device_automounter Qt::DBus KF5::CoreAddons KF5::Service KF5::ConfigCore KF5::ConfigGui KF5::DBusAddons KF5::Solid)

install(TARGETS kded_device_automounter DESTINATION ${KDE_INSTALL_PLUGINDIR}/kf5/kded)
