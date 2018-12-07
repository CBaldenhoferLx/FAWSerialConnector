import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtWebEngine 1.7

Window {
    visible: true
    width: 800
    height: 600
    title: qsTr("FAW Demo")

    ColumnLayout {
        anchors.fill: parent

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 40

            ComboBox {
                id: port1
                Layout.preferredWidth: 200
                model: SerialConnector.availablePorts
                editable: true
                enabled: !SerialConnector.isConnected
            }

            ComboBox {
                id: port2
                Layout.preferredWidth: 200
                model: SerialConnector.availablePorts
                editable: true
                enabled: !SerialConnector.isConnected
            }

            Button {
                text: SerialConnector.isConnected ? qsTr("Disconnect") : qsTr("Connect")
                Layout.preferredWidth: 200
                enabled: port1.currentText!=port2.currentText

                onClicked: {
                    if (SerialConnector.isConnected) {
                        SerialConnector.disconnect()
                    } else {
                        SerialConnector.connect(port1.currentText, port2.currentText)
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            //Layout.fillHeight: true

            LogView {
                id: comm

                Layout.fillWidth: true
                Layout.fillHeight: true

                showCmd: false

                title: qsTr("Communication")
            }

            LogView {
                id: log1

                Layout.fillWidth: true
                Layout.fillHeight: true

                title: qsTr("Dashboard")

                portName: port1.currentText
            }

            LogView {
                id: log2

                Layout.fillWidth: true
                Layout.fillHeight: true

                title: qsTr("Back Control")

                portName: port2.currentText
            }
        }
    }

    Connections {
        target: SerialConnector

        onAvailablePortsChanged: {
            if (port2.count>1 && port1.currentIndex==port2.currentIndex) {
                port2.currentIndex=port2.currentIndex+1
            }
        }

        onLogMessage: {
            if (port1.currentText==port) {
                log1.content+=message
            } else {
                log2.content+=message
            }
        }

        onCommMessage: {
            comm.content+=source + " -> " + target + " " + msg
        }
    }
}
