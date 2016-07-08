/*
 * This file is part of RPI Car System.
 * Copyright (c) 2016 Fabien Caylus <tranqyll.dev@gmail.com>
 *
 * This file is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.3
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtGraphicalEffects 1.0
import "."

ButtonStyle {
    background: Rectangle {
        color: control.pressed ? Style.button.colorPressed : Style.button.color

        Rectangle {
            height: 1
            width: parent.width
            anchors.top: parent.top
            color: inToolbar ? Style.toolbar.topBorderColor : Style.button.topBorderColor
            visible: !control.pressed
        }
    }

    label: Item {
        implicitWidth: col.implicitWidth
        implicitHeight: col.implicitHeight
        baselineOffset: col.y + hText.y + hText.baselineOffset

        Column {
            id: col
            anchors.left: control.text.length === 0 ? undefined : parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter

            Image {
                asynchronous: true
                source: (hasSecondIcon && currentState == (statesNumber-1)) ? secondIcon : control.iconSource
                height: control.height * iconScale
                width: Math.min(sourceSize.width, height)
                fillMode: Image.PreserveAspectFit

                ColorOverlay {
                    anchors.fill: parent
                    source: parent
                    color: control.pressed ? Style.button.clickedOverlayColor
                                                : Style.button.checkedOverlayColor
                    visible: control.pressed || control.checked
                }
            }

            StyledText {
                id: hText
                text: control.text
                font.pixelSize: control.height * fontRatio
                horizontalAlignment: alignCenter ? Text.AlignHCenter : Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                anchors.horizontalCenter: parent.horizontalCenter
                font.bold: bold

                // Handle clicked and checked states
                Connections {
                    target: control
                    onPressedChanged: {
                        hText.color = pressed ? Style.button.clickedOverlayColor : Style.fontColor
                    }
                    onCheckedChanged: {
                        hText.color = checked ? Style.button.checkedOverlayColor : Style.fontColor
                    }
                }
            }
        }
    }
}
