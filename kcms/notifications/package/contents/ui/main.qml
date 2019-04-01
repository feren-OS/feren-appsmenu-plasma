/*
 * Copyright 2019 Kai Uwe Broulik <kde@privat.broulik.de>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License or (at your option) version 3 or any later version
 * accepted by the membership of KDE e.V. (or its successor approved
 * by the membership of KDE e.V.), which shall act as a proxy
 * defined in Section 14 of version 3 of the license.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.9
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.3 as QtControls
import org.kde.kirigami 2.4 as Kirigami
import org.kde.kcm 1.2 as KCM

import org.kde.notificationmanager 1.0 as NotificationManager

KCM.SimpleKCM {
    KCM.ConfigModule.quickHelp: i18n("This module lets you manage application and system notifications.")
    KCM.ConfigModule.buttons: KCM.ConfigModule.Help | KCM.ConfigModule.Default | KCM.ConfigModule.Apply

    implicitHeight: 550 // HACK FIXME

    Binding {
        target: kcm
        property: "needsSave"
        value: kcm.settings.dirty // TODO or other stuff
    }

    Kirigami.FormLayout {
        QtControls.CheckBox {
            Kirigami.FormData.label: i18n("Critical notifications:")
            text: i18n("Show in do not disturb mode")
            checked: kcm.settings.criticalPopupsInDoNotDisturbMode
            onClicked: kcm.settings.criticalPopupsInDoNotDisturbMode = checked
        }

        QtControls.CheckBox {
            text: i18n("Always keep on top")
            checked: kcm.settings.keepCriticalAlwaysOnTop
            onClicked: kcm.settings.keepCriticalAlwaysOnTop = checked
        }

        QtControls.CheckBox {
            Kirigami.FormData.label: i18n("Low priority notifications:")
            text: i18n("Show popup")
            checked: kcm.settings.lowPriorityPopups
            onClicked: kcm.settings.lowPriorityPopups = checked
        }

        QtControls.ButtonGroup {
            id: positionGroup
            buttons: [positionNearWidget, positionCustomPosition]
        }

        QtControls.RadioButton {
            id: positionNearWidget
            Kirigami.FormData.label: i18n("Popup position:")
            text: i18nc("Popup position near notification plasmoid", "Near the notification icon") // "widget"
            checked: kcm.settings.popupPosition === NotificationManager.Settings.NearWidget
            onClicked: kcm.settings.popupPosition = NotificationManager.Settings.NearWidget
        }

        RowLayout {
            spacing: 0
            QtControls.RadioButton {
                id: positionCustomPosition
                checked: kcm.settings.popupPosition !== NotificationManager.Settings.NearWidget
                activeFocusOnTab: false

                MouseArea {
                    anchors.fill: parent
                    onClicked: positionCustomButton.clicked()
                }
            }
            QtControls.Button {
                id: positionCustomButton
                text: i18n("Choose Custom Position...")
                icon.name: "preferences-desktop-display"
                onClicked: kcm.push("PopupPositionPage.qml")
            }
        }

        TextMetrics {
            id: timeoutSpinnerMetrics
            font: timeoutSpinner.font
            text: i18np("%1 second", "%1 seconds", 888)
        }

        QtControls.SpinBox {
            id: timeoutSpinner
            Kirigami.FormData.label: i18n("Hide popup after:")
            Layout.preferredWidth: timeoutSpinnerMetrics.width + leftPadding + rightPadding
            from: 1000 // 1 second
            to: 120000 // 2 minutes
            stepSize: 1000
            value: kcm.settings.popupTimeout
            editable: true
            valueFromText: function(text, locale) {
                return parseInt(text) * 1000;
            }
            textFromValue: function(value, locale) {
                return i18np("%1 second", "%1 seconds", Math.round(value / 1000));
            }
            onValueModified: kcm.settings.popupTimeout = value
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
        }

        QtControls.CheckBox {
            Kirigami.FormData.label: i18n("Application progress:")
            text: i18n("Show in task manager")
            checked: kcm.settings.jobsInTaskManager
            onClicked: kcm.settings.jobsInTaskManager = checked
        }

        QtControls.CheckBox {
            id: applicationJobsEnabledCheck
            text: i18nc("Show application jobs in notification widget", "Show in notifications")
            checked: kcm.settings.jobsInNotifications
            onClicked: kcm.settings.jobsInNotifications = checked
        }

        RowLayout { // just for indentation
            QtControls.CheckBox {
                Layout.leftMargin: indicator.width
                text: i18nc("Keep application job popup open for entire duration of job", "Keep popup open during progress")
                enabled: applicationJobsEnabledCheck.checked
                checked: kcm.settings.permanentJobPopups
                onClicked: kcm.settings.permanentJobPopups = checked
            }
        }

        QtControls.CheckBox {
            Kirigami.FormData.label: i18n("Notification badges:")
            text: i18n("Show in task manager")
            checked: kcm.settings.badgesInTaskManager
            onClicked: kcm.settings.badgesInTaskManager = checked
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
        }

        QtControls.Button {
            Kirigami.FormData.label: i18n("Applications:")
            text: i18n("Configure...")
            icon.name: "configure"
            onClicked: kcm.push("SourcesPage.qml")
        }
    }
}
