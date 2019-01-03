import QtQuick 2.0

Item {
    id: root

    signal triggered()
    property bool switchActive: false
    property bool moveActive: false

    Rectangle {
        color: "black"

        width: 72
        height: 4

        radius: 3

        visible: switchActive
    }

    Image {
        id: arrowImage
        source: "arrow.png"
    }

    MouseArea {
        anchors.fill: arrowImage

        onClicked: {
            root.triggered()

            /*
            console.log(root, root.x, " ", root.y)
            root.forceActiveFocus()
            */
        }
    }

    Timer {
        running: moveActive

        interval: 300
        repeat: true

        onTriggered: {
            arrowImage.visible = !arrowImage.visible
        }

        onRunningChanged: {
            arrowImage.visible = true
        }
    }

    /*
    Keys.onLeftPressed: {
        root.x = root.x - 2
        console.log(root.x, " ", root.y)
    }

    Keys.onRightPressed: {
        root.x = root.x + 2
        console.log(root.x, " ", root.y)
    }

    Keys.onUpPressed: {
        root.y = root.y - 2
        console.log(root.x, " ", root.y)
    }

    Keys.onDownPressed: {
        root.y = root.y + 2
        console.log(root.x, " ", root.y)
    }*/
}
