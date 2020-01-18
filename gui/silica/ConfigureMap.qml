/*
 * Copyright (C) 2020
 *      Jean-Luc Barriere <jlbarriere68@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.2
import Sailfish.Silica 1.0
import Osmin 1.0
import "./components"

PopOver {
    id: configureMap

    title: "Configure Map"
    contents: Column {
        spacing: units.gu(1)

        MapCheckBox {
            id: rotate
            width: parent.width
            color: styleMap.popover.foregroundColor
            text: qsTr("Map rotation")
            checked: mapUserSettings.rotateEnabled
            onClicked: {
                mapUserSettings.rotateEnabled = !mapUserSettings.rotateEnabled;
            }
        }

        MapCheckBox {
            id: hillShading
            width: parent.width
            color: styleMap.popover.foregroundColor
            text: qsTr("Hill Shades")
            checked: mapUserSettings.hillShadesEnabled
            onClicked: {
                mapUserSettings.hillShadesEnabled = !mapUserSettings.hillShadesEnabled;
            }
        }

        MapCheckBox {
            id: seaRendering
            width: parent.width
            color: styleMap.popover.foregroundColor
            text: qsTr("Render Sea")
            checked: mapEngineSettings.renderSea
            onClicked: {
                mapEngineSettings.renderSea = !mapEngineSettings.renderSea;
            }
        }

        MapCheckBox {
            id: showAltLanguage
            width: parent.width
            color: styleMap.popover.foregroundColor
            text: qsTr("Prefer English names")
            checked: mapEngineSettings.showAltLanguage
            onClicked: {
                mapEngineSettings.showAltLanguage = !mapEngineSettings.showAltLanguage;
            }
        }

        ComboBox {
            id: mapStyleSheet
            width: parent.width
            label: qsTr("Style")
            labelColor: styleMap.popover.foregroundColor
            leftMargin: 0
            rightMargin: 0
            menu: ContextMenu {
                Repeater {
                    model: mapStyle
                    MenuItem { text: name }
                }
            }
            onCurrentItemChanged: {
                if (currentIndex >= 0) {
                    var stylesheet = mapStyle.file(currentIndex);
                    mapStyle.style = stylesheet;
                }
            }
            MapStyleModel { id: mapStyle }
            Component.onCompleted: {
                var stylesheet = mapStyle.style;
                currentIndex = mapStyle.indexOf(stylesheet);
            }
        }

        ComboBox {
            id: fontName
            width: parent.width
            label: qsTr("Font name")
            labelColor: styleMap.popover.foregroundColor
            leftMargin: 0
            rightMargin: 0
            menu: ContextMenu {
                MenuItem { text: qsTr("DejaVu Sans") }
                MenuItem { text: qsTr("Droid Serif") }
                MenuItem { text: qsTr("Liberation Sans") }
            }
            onCurrentItemChanged: {
                if (currentIndex >= 0) {
                    mapEngineSettings.fontName = currentItem.text;
                }
            }
            Component.onCompleted: currentIndex = indexOfValue(mapEngineSettings.fontName)
            function indexOfValue(val) {
                if (val === "DejaVu Sans")
                    return 0;
                if (val === "Droid Serif")
                    return 1;
                if (val === "Liberation Sans" )
                    return 2;
                return 0;
            }
        }

        ComboBox {
            id: fontSize
            width: parent.width
            label: qsTr("Font size")
            labelColor: styleMap.popover.foregroundColor
            leftMargin: 0
            rightMargin: 0
            menu: ContextMenu {
                MenuItem { text: qsTr("Normal");    property real value: 2.0; }
                MenuItem { text: qsTr("Big");       property real value: 3.0; }
                MenuItem { text: qsTr("Bigger");    property real value: 4.0; }
                MenuItem { text: qsTr("Huge");      property real value: 6.0; }
            }
            onCurrentItemChanged: {
                if (currentIndex >= 0) {
                    mapEngineSettings.fontSize = currentItem.value;
                }
            }
            Component.onCompleted: currentIndex = indexOfValue(mapEngineSettings.fontSize)
            function indexOfValue(val) {
                if (val <= 2.0)
                    return 0;
                if (val <= 3.0)
                    return 1;
                if (val <= 4.0)
                    return 2;
                return 3;
            }
        }

        Column {
            width: parent.width
            MapCheckBox {
                id: renderingType
                width: parent.width
                color: styleMap.popover.foregroundColor
                text: qsTr("Tiled rendering (lower quality)")
                checked: mapUserSettings.renderingTypeTiled
                onClicked: {
                    mapUserSettings.renderingTypeTiled = !mapUserSettings.renderingTypeTiled;
                }
            }
            Label {
                text: "It supports map rotating, but labels are rotated too. Rendering may be more responsive, due to tile caching in memory."
                width: parent.width
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignJustify
                maximumLineCount: 4
                wrapMode: Text.Wrap
                color: foregroundColor
                font.pixelSize: units.fx("x-small")
                font.weight: Font.Normal
            }
        }
    }
}
