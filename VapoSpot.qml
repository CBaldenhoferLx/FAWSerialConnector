import QtQuick 2.0
import QtGraphicalEffects 1.12

Item {
    id: root

    property string identifier
    property bool isActive: false
    property alias level: vapoLevel.text

    width: vapoImage.paintedWidth
    height: vapoImage.paintedHeight

    MouseArea {
        anchors.fill: parent

        onClicked: {
            SerialConnector.sendCmd(1, "v" + identifier + "5")
        }
    }

    Image {
        id: vapoImage
        source: "vapo.png"
    }

    ColorOverlay {
        anchors.fill: vapoImage
        source: vapoImage
        color: isActive ? "#aa0000ff" : "transparent"
    }

    Text {
        id: vapoLevel

        anchors.top: vapoImage.bottom
        anchors.left: vapoImage.left
        anchors.right: vapoImage.right
        anchors.topMargin: 5

        horizontalAlignment: Text.AlignHCenter

        text: "n/a"
    }

}
