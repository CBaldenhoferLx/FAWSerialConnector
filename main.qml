import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3

Window {
    visible: true
    width: 800
    height: 600
    title: qsTr("FAW Demo")

    function connect() {
        SerialConnector.connect(port1.currentText, port2.currentText)
        log1.clear()
        log2.clear()
        comm.clear()
    }

    ColumnLayout {
        anchors.fill: parent

        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 40

            Text {
                text: qsTr("Dashboard")
            }

            ComboBox {
                id: port1
                Layout.preferredWidth: 200
                model: SerialConnector.availablePorts
                editable: true
                enabled: !SerialConnector.isConnected
            }

            Text {
                text: qsTr("Back Control")
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
                        connect()
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

                showExcludePing: true

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

            var p1 = SerialConnector.getSetting("port1", "");
            var p2 = SerialConnector.getSetting("port2", "");

            var pi = port1.find(p1);
            if (p1 && pi!==-1) {
                port1.currentIndex = pi;
            }

            pi = port2.find(p2);
            if (p2 && pi!==-1) {
                port2.currentIndex = pi;
            }

            if (SerialConnector.getSetting("autoStart", false)) {
                connect()
            }
        }

        onLogMessage: {
            if (port1.currentText==port) {
                log1.appendLog(message)
            } else {
                log2.appendLog(message)
            }
        }

        onCommMessage: {
            comm.appendLog(source + " -> " + target + " " + msg)
        }
    }
}
