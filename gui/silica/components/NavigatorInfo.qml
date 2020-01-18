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

Item {
    id: navigationInfo
    property Navigator navigator

    property color backgroundColor: styleMap.popover.backgroundColor
    property color foregroundColor: styleMap.popover.foregroundColor
    property real edgeMargins: units.gu(0.5)
    property real contentTopMargin: units.gu(5) // header bar
    property real contentEdgeMargins: units.gu(2)
    property real contentSpacing: units.gu(1)
    readonly property real minimumHeight: units.gu(6)
    property real maximumHeight: parent.height

    signal show
    signal close // triggered on button close pressed

    z: 99
    focus: true
    height: minimumHeight

    function resizeBox(contentHeight) {
        height = Math.min(Math.max(minimumHeight, contentHeight + contentTopMargin + contentEdgeMargins), maximumHeight);
    }

    onVisibleChanged: {
        if (visible) {
            var h = (contents.contentHeight + contentSpacing);
            resizeBox(h);
        }
    }

    states: [
        State {
            name: "running"
        },
        State {
            name: "suspended"
        }
    ]
    state: "running"

    Connections {
        target: navigator
        onRerouteRequested: {
            state = "suspended"
        }
    }

    // background
    Rectangle {
        id: popover
        anchors.fill: parent
        anchors.margins: edgeMargins
        color: backgroundColor
        radius: units.gu(1)
    }

    SilicaFlickable {
        id: contents
        anchors.fill: popover
        anchors.topMargin: contentTopMargin
        anchors.leftMargin: contentEdgeMargins
        anchors.rightMargin: contentEdgeMargins
        anchors.bottomMargin: contentEdgeMargins
        contentHeight: contentsColumn.height
        boundsBehavior: Flickable.StopAtBounds
        clip: true

        Column {
            id: contentsColumn
            opacity: navigationInfo.state === "running" ? 1.0 : 0.0
            spacing: contentSpacing
            width: parent.width
            Row {
                id: rowStep
                spacing: units.gu(2)
                width: parent.width
                height: Math.max(distanceToNextStep.implicitHeight + contentSpacing + nextStepDescription.implicitHeight, icon.height)

                WAYIcon {
                    id: icon
                    anchors.verticalCenter: parent.verticalCenter
                    color: styleMap.popover.foregroundColor
                    stepType: navigator.nextRouteStep.type
                    roundaboutExit: navigator.nextRouteStep.roundaboutExit
                    roundaboutClockwise: navigator.nextRouteStep.roundaboutClockwise
                    width: units.gu(7)
                    height: width
                    label.text: navigator.nextRouteStep.type === "leave-roundabout" ? navigator.nextRouteStep.roundaboutExit : ""
                }
                Column {
                    spacing: contentSpacing
                    Label {
                        id: distanceToNextStep
                        text: Converter.readableDistance(navigator.nextRouteStep.distanceTo)
                        color: styleMap.popover.foregroundColor
                        font.pixelSize: units.fx("x-large")
                    }
                    Text {
                        id: nextStepDescription
                        text: navigator.nextRouteStep.shortDescription
                        font.pixelSize: units.fx("large")
                        color: styleMap.popover.foregroundColor
                        wrapMode: Text.Wrap
                    }
                }
            }
        }
    }

    MapIcon {
        id: resume
        source: "qrc:/images/trip/route.svg"
        height: units.gu(7)
        anchors.centerIn: contents
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: contentEdgeMargins
        anchors.rightMargin: contentEdgeMargins
        color: styleMap.popover.foregroundColor
        onClicked: {
            navigationInfo.state = "running";
            navigator.reroute();
        }
        label.text: qsTr("Resume navigation")
        visible: navigationInfo.state === "suspended"
        enabled: visible
    }

    BusyIndicator{
        id: reroutingIndicator
        running: navigator.routeRunning
        size: units.gu(7)
        anchors.verticalCenter: contents.verticalCenter
        anchors.right: contents.right
        visible: running
    }

    Item {
        id: board
        anchors.verticalCenter: closeButton.verticalCenter
        anchors.left: popover.left
        anchors.right: closeButton.left
        anchors.leftMargin: contentEdgeMargins
        anchors.rightMargin: contentEdgeMargins
        height: minimumHeight

        Row {
            id: headInfo
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width
            spacing: units.gu(1)

            Label {
                id: speed
                anchors.verticalCenter: parent.verticalCenter
                text: Converter.readableSpeed(navigator.currentSpeed > 0 ? navigator.currentSpeed : 0.0)
                color: styleMap.popover.foregroundColor
                font.pixelSize: units.fx("x-large")
            }
            Label {
                id: maxspeed
                anchors.verticalCenter: parent.verticalCenter
                text: navigator.maximumSpeed > 0 ? Converter.readableSpeed(navigator.maximumSpeed) : ""
                color: styleMap.view.highlightedColor
                font.pixelSize: units.fx("medium")
            }
            Label {
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("ETA")
                color: styleMap.popover.foregroundColor
                font.pixelSize: units.fx("medium")
            }
            Label {
                id: eta
                anchors.verticalCenter: parent.verticalCenter
                text: navigator.arrivalEstimate + " ~ " + Converter.panelDistance(navigator.remainingDistance)
                color: styleMap.popover.foregroundColor
                font.pixelSize: units.fx("medium")
            }
        }
    }

    // close button
    MapIcon {
        id: closeButton
        source: "image://theme/icon-m-cancel"
        height: units.gu(5)
        anchors.top: popover.top
        anchors.right: popover.right
        color: foregroundColor
        onClicked: {
            console.log("close navigator info");
            close();
        }
    }
}