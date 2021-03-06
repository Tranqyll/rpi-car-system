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
import rpicarsystem.mediamanager 1.0
import ".."
import "."

//
// Each mode had it's own list views
//

Item {
    id: musicLister

    property bool started: mediaManager.scanned
    property bool firstClicked: false

    Component.onCompleted: {
        var lastMainView = musicPlayer.lastMainViewType
        switch(lastMainView) {
            case 0:
                artistButton.click()
                break;
            case 1:
                albumButton.click()
                break;
            case 2:
                trackButton.click()
                break;
            case 3:
                playlistButton.click()
                break;
        }

        firstClicked = true

        // Update history status
        loader.loadPreviousHistory()
    }

    Component.onDestruction: {
        loader.appendLastEntry()
    }

    StyledText {
        id: waitText
        visible: !started
        width: parent.width
        height: parent.height
        text: qsTr("Search for music files ...");
        font.pixelSize: 25
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    Row {
        id: mainRow
        visible: started
        anchors.fill: parent
        anchors.leftMargin: 5
        anchors.rightMargin: 5
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter

        spacing: 10

        // Used to choose correct mode
        Column {
            y: 5
            width: 200
            spacing: 5

            SelectViewButton {
                id: artistButton
                width: parent.width
                text: qsTr("Artists")

                onClicked: loader.loadTopLevelView("qrc:/qml/music/ListViewArtist.qml", qsTr("Artists list ..."))
            }

            SelectViewButton {
                id: albumButton
                width: parent.width
                text: qsTr("Albums")

                onClicked: loader.loadTopLevelView("qrc:/qml/music/ListViewAlbum.qml", qsTr("Albums list ..."))
            }

            SelectViewButton {
                id: trackButton
                width: parent.width
                text: qsTr("Tracks")

                onClicked: loader.loadTopLevelView("qrc:/qml/music/ListViewTrack.qml", qsTr("Tracks list ..."))
            }

            SelectViewButton {
                id: playlistButton
                width: parent.width
                text: qsTr("Playlists")

                onClicked: loader.loadTopLevelView("qrc:/qml/music/ListViewPlaylist.qml", qsTr("Playlists ..."))
            }

            FlatButton {
                width: 80
                height: width
                anchors.horizontalCenter: parent.horizontalCenter
                iconSource: "qrc:/images/back"
                onClicked: loader.loadPreviousHistory()
                visible: musicPlayer.hasHistoryEntry
            }
        }

        Rectangle {
            height: parent.height
            width: 2
            color: Style.separatorColor
        }
        Rectangle {
            height: parent.height
            width: 2
            color: Style.separatorColor
        }
        Rectangle {
            height: parent.height
            width: 2
            color: Style.separatorColor
        }

        Loader {
            id: loader
            focus: true

            width: mainRow.width - 200 - 2*3 - 10*4
            height: parent.height - 2

            asynchronous: true
            visible: status == Loader.Ready

            property string headerText
            property int meta: MediaInfo.UNKNOWN
            property var metaValue
            property bool inPlaylist: false
            property string playlistFile

            function appendLastEntry() {
                musicPlayer.addHistoryEntry(source, meta, metaValue, headerText, inPlaylist, playlistFile)
            }

            function loadTopLevelView(sourceUri, title) {
                // Do nothing if the view is already selected
                // Use "==" and not "===" since sourceUri is a string and source an url
                if(source == sourceUri
                        && meta === MediaInfo.UNKNOWN
                        && metaValue === undefined
                        && inPlaylist === false) {
                    return
                }

                // Small trick to avoid addition of the first entry
                // "firstClicked" is set to true only after the first add
                if(firstClicked) {
                    loader.appendLastEntry()
                }

                loader.headerText = title
                loader.meta = MediaInfo.UNKNOWN
                loader.metaValue = undefined
                loader.inPlaylist = false
                loader.playlistFile = ""
                loader.source = ""
                loader.source = sourceUri
            }

            function loadPreviousHistory() {
                if(musicPlayer.hasHistoryEntry) {
                    headerText = musicPlayer.lastHistoryEntryHeaderText()
                    meta = musicPlayer.lastHistoryEntryMeta()
                    metaValue = musicPlayer.lastHistoryEntryMetaValue()
                    inPlaylist = musicPlayer.lastHistoryEntryInPlaylist()
                    playlistFile = musicPlayer.lastHistoryEntryPlaylistFile()

                    source = ""
                    source = musicPlayer.lastHistoryEntrySource()

                    musicPlayer.removeLastHistoryEntry()
                }
            }
        }
    }

    PlaylistPopup {
        id: playlistPopup
        visible: false
    }

    // userData  --> playlist name
    // userData2 --> playlist file
    ConfirmationPopup {
        id: removePlaylistPopup
        visible: false

        highlightNoButton: true
        highlightYesButton: false

        title: qsTr("Are you sure to remove \"%1\" playlist ?").arg(userData)

        onExitSuccess: {
            mediaManager.removePlaylist(userData2)
        }
    }

    // userData --> playlist file
    // userData2 --> music file
    // userData3 --> music title
    ConfirmationPopup {
        id: removeFromPlaylistPopup
        visible: false

        highlightNoButton: true
        highlightYesButton: false

        title: qsTr("Are you sure to remove \"%1\" from the playlist ?").arg(userData3)

        onExitSuccess: {
            mediaManager.removeMediaFromPlaylist(userData, userData2)

            // Reload current view
            var src = loader.source
            loader.source = ""
            loader.source = src
        }
    }
}

