import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.4

Item {
    height: 16

    RowLayout {
        anchors.fill: parent

        anchors.margins: 2

        Text {
            id: p1Text
            text: p1

            font.pointSize: 9

            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }
}
