/*
    SPDX-FileCopyrightText: 2018 Tomaz Canabrava <tcanabrava@kde.org>

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kirigami.delegates as KD
import org.kde.kcmutils as KCMUtils
import org.kde.kwindowsystem

KCMUtils.AbstractKCM {
    id: root

    implicitWidth: Kirigami.Units.gridUnit * 45
    implicitHeight: Kirigami.Units.gridUnit * 25

    framedView: false

    property var elements: [
        {
            icon: "zoom-in",
            title: i18nc("@title Category name in sidebar", "Zoom & Magnifier"),
            defaultnessKey: "zoomMagnifierIsDefaults"
        },
        {
            icon: "notifications",
            title: i18nc("@title Category name in sidebar", "System Bell"),
            defaultnessKey: "bellIsDefaults"
        },
        {
            icon: "input-keyboard",
            title: i18nc("System Modifier Keys", "Modifier Keys"),
            defaultnessKey: "keyboardModifiersIsDefaults"
        },
        {
            icon: "view-filter",
            title: i18nc("System keyboard filters", "Keyboard Filters"),
            defaultnessKey: "keyboardFiltersIsDefaults"
        },
        {
            icon: "input-mouse",
            title: i18nc("System mouse navigation", "Mouse Navigation"),
            defaultnessKey: "mouseIsDefaults"
        },
        {
            icon: "input-caps-on",
            title: i18n("Activation Shortcuts"),
            defaultnessKey: "activationGesturesIsDefaults"
        },
        {
            icon: "text-speak",
            title: i18nc("System mouse navigation", "Screen Reader"),
            defaultnessKey: "screenReaderIsDefaults"
        },
        {
            icon: "view-visible",
            title: i18nc("Correction for color blindness", "Color Blindness Correction"),
            defaultnessKey: "colorblindnessCorrectionIsDefaults"
        },
        {
            icon: "image-invert-symbolic",
            title: i18nc("@title Category name in sidebar, for inverting screen colors", "Invert"),
            defaultnessKey: "invertIsDefaults"
        },
        {
            icon: "cursor-arrow",
            title: i18nc("Shake cursor to find it", "Shake Cursor"),
            defaultnessKey: "shakeCursorIsDefaults",
            available: KWindowSystem.isPlatformWayland
        }
    ]

    RowLayout {
        id: mainLayout
        anchors.fill: parent
        spacing: 0

        QQC2.ScrollView {
            id: leftSidePaneBackground
            Layout.fillHeight: true
            Layout.minimumWidth: Kirigami.Units.gridUnit * 13

            Kirigami.Theme.colorSet: Kirigami.Theme.View
            Kirigami.Theme.inherit: false

            ListView {
                id: listView
                activeFocusOnTab: true
                clip: true
                keyNavigationEnabled: true
                model: root.elements

                delegate: QQC2.ItemDelegate {
                    id: baseDelegate

                    required property int index
                    required property var modelData

                    width: listView.width

                    highlighted: listView.currentIndex === index

                    icon.name: modelData.icon
                    text: modelData.title
                    visible: modelData.available === undefined || modelData.available

                    onClicked: {
                        listView.currentIndex = index
                        listView.forceActiveFocus()
                    }

                    contentItem: RowLayout {
                        spacing: Kirigami.Units.smallSpacing

                        KD.IconTitleSubtitle {
                            Layout.fillWidth: true
                            icon.name: baseDelegate.icon.name
                            title: baseDelegate.text
                            selected: baseDelegate.highlighted || baseDelegate.down
                        }

                        Rectangle {
                            radius: width * 0.5
                            implicitWidth: Kirigami.Units.largeSpacing
                            implicitHeight: Kirigami.Units.largeSpacing
                            visible: kcm.defaultsIndicatorsVisible
                            opacity: !kcm[modelData.defaultnessKey]
                            color: Kirigami.Theme.neutralTextColor
                        }
                    }
                }
            }
        }

        Kirigami.Separator {
            Layout.fillHeight: true
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Kirigami.Theme.colorSet: Kirigami.Theme.Window
            Kirigami.Theme.inherit: false
            color: Kirigami.Theme.backgroundColor

            QQC2.ScrollView {
                id: scrollView
                anchors.fill: parent

                Item {
                    id: containerItem
                    // Ensures we have correct margins on our content, which should
                    // fill the scrollView or scroll vertically when larger

                    readonly property int margins: Kirigami.Units.gridUnit

                    width: scrollView.availableWidth
                    height: Math.max(implicitHeight, scrollView.availableHeight)
                    // NOTE: No need to calculate implicitWidth, as we don't use it for sizing and
                    //       if present, the ScrollView will use it to show horizontal scroll bars
                    //implicitWidth: stackLayout.implicitWidth + margins * 2
                    implicitHeight: stackLayout.implicitHeight + margins * 2

                    StackLayout {
                        id: stackLayout
                        anchors.fill: parent
                        anchors.margins: containerItem.margins

                        currentIndex: listView.currentIndex

                        ZoomMagnifier {}
                        Bell {}
                        ModifierKeys {}
                        KeyboardFilters {}
                        MouseNavigation {}
                        ActivationShortcuts {}
                        ScreenReader {}
                        ColorblindnessCorrection {}
                        Invert {}
                        ShakeCursor {}
                    }
                }
            }
        }
    }
}
