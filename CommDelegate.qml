import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.4

Item {
    height: 20

    Rectangle {
        anchors.fill: parent
        anchors.leftMargin: 1
        anchors.rightMargin: 1

        color: c

        RowLayout {
            anchors.fill: parent

            anchors.margins: 2

            Text {
                id: p1Text
                text: p1

                font.pointSize: 9

                Layout.fillHeight: true
                Layout.preferredWidth: 50
            }
            Text {
                text: p2

                font.pointSize: 9
                Layout.fillHeight: true
                Layout.preferredWidth: 120
            }
            Text {
                text: p3

                font.pointSize: 9
                Layout.fillHeight: true
                Layout.fillWidth: true
            }
            Text {
                text: p4

                font.pointSize: 9
                Layout.fillHeight: true
                Layout.preferredWidth: 60
            }
        }
    }
}
