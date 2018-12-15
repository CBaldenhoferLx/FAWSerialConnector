import QtQuick 2.11
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.3

Item {
    height: 24

    z: 10

    Rectangle {
        anchors.fill: parent
        anchors.leftMargin: 1
        anchors.rightMargin: 1

        color: "white"

        RowLayout {
            anchors.fill: parent
            anchors.margins: 2

            Label {
                Layout.fillHeight: true
                Layout.preferredWidth: 50

                text: qsTr("Port")

                font.pointSize: 10
                font.bold: true
            }
            Label {
                text: qsTr("Cmd")

                font.pointSize: 10
                font.bold: true
                Layout.fillHeight: true
                Layout.preferredWidth: 120
            }
            Label {
                text: qsTr("Mod")

                font.pointSize: 10
                font.bold: true
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
            Label {
                text: qsTr("Val")

                font.pointSize: 10
                font.bold: true
                Layout.fillHeight: true
                Layout.preferredWidth: 60
            }
        }
    }
}
