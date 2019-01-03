import QtQuick 2.11
import QtQuick.Controls 2.4

Item {
    property alias isRunning: fanTimer.running
    property alias strength: fanStrength.value

    Timer {
        id: fanTimer

        repeat: true
        interval: 1000 / (fanStrength.value+1)
        running: fanStrength.value>0

        onTriggered: {
            fanImage.source = (fanImage.source=="qrc:/fan.png" ? "fan2.png" : "fan.png")
        }
    }


    Image {
        id: fanImage

        source: "fan.png"
    }

    Slider {
        id: fanStrength

        anchors.top: fanImage.bottom
        anchors.horizontalCenter: fanImage.horizontalCenter

        from: 0
        to: 9
        width: 100
        stepSize: 1

        onMoved: {
            SerialConnector.sendCmd(1, "fx" + value)
        }

        Text {
            text: parent.value
        }
    }

}
