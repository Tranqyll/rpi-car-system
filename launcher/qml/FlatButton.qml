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

import QtQuick 2.5
import rpicarsystem.controls 1.0
import QtGraphicalEffects 1.0
import "."

AbstractButton {
    id: but
    property url iconSource

    background: Rectangle {
        color: "transparent"
    }

    label: Image {
        id: buttonImg
        asynchronous: true
        height: but.height
        width: but.width
        sourceSize.width: width
        sourceSize.height: height
        fillMode: Image.PreserveAspectFit

        source: but.iconSource

        ColorOverlay {
            anchors.fill: parent
            source: parent
            color: Style.button.clickedOverlayColor
            visible: but.pressed
        }
    }
}
