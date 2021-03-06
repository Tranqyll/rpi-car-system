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
import "."
import "./settings"

Activity {
    id: activitySettings

    control: GridMenu {
        expectedDepth: 2

        property Component settingsEqualizer: SettingsEqualizer {}
        property Component settingsClean: SettingsClean {}
        property Component settingsUpdate: SettingsUpdate {}
        property Component settingsLanguage: SettingsLanguage {}
        property Component settingsSystem: SettingsSystem {}
        property Component settingsAbout: SettingsAbout {}

        map: {
            1: settingsEqualizer,
            2: settingsClean,
            3: settingsUpdate,
            4: settingsLanguage,
            5: settingsSystem,
            6: settingsAbout
        }

        model: ListModel {
            ListElement {
                index: 1
                isEnabled: true
                title: qsTr("Equalizer")
                icon: "qrc:/images/equalizer"
            }
            ListElement {
                index: 2
                isEnabled: true
                title: qsTr("Clean system")
                icon: "qrc:/images/folder"
            }
            ListElement {
                index: 3
                isEnabled: true
                title: qsTr("Update")
                icon: "qrc:/images/update"
            }
            ListElement {
                index: 4
                isEnabled: true
                title: qsTr("Languages")
                icon: "qrc:/images/world"
            }
            ListElement {
                index: 5
                isEnabled: true
                title: qsTr("System")
                icon: "qrc:/images/build"
            }
            ListElement {
                index: 6
                isEnabled: true
                title: qsTr("About")
                icon: "qrc:/images/info"
            }
        }
    }
}
