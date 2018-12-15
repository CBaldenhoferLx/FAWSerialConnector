import QtQuick 2.0
import QtQuick.Controls 2.4

Item {
    height: 24

    z: 10

    Rectangle {
        anchors.fill: parent
        anchors.leftMargin: 1
        anchors.rightMargin: 1

        color: "white"

        Label {
            anchors.fill: parent
            anchors.margins: 2

            text: qsTr("Message")

            font.pointSize: 10
            font.bold: true
        }
    }
}
