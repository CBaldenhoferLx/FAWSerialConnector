import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3

Window {
    visible: true
    width: 1024
    height: 768
    title: qsTr("FAW Demo")

    property string dashboardColor: "beige"
    property string backControlColor: "honeydew"

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

            Rectangle {
                Layout.preferredWidth: dbLabel.width
                Layout.preferredHeight: 40

                color: dashboardColor

                Text {
                    id: dbLabel
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    verticalAlignment: Text.AlignVCenter

                    text: qsTr("Dashboard")
                }
            }


            ComboBox {
                id: port1
                Layout.preferredWidth: 200
                model: SerialConnector.availablePorts
                editable: true
                enabled: !SerialConnector.isConnected
            }

            Rectangle {
                Layout.preferredWidth: backControlLabel.width
                Layout.preferredHeight: 40

                color: backControlColor

                Text {
                    id: backControlLabel
                    text: qsTr("Back Control")

                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    verticalAlignment: Text.AlignVCenter
                }
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

            spacing: 1

            LogView {
                id: comm

                Layout.fillWidth: true
                Layout.fillHeight: true

                showExcludePing: true
                showLogToFile: true

                showCmd: false

                title: qsTr("Communication")

                listDelegate: Component {
                    CommDelegate {
                        width: comm.width
                    }
                }

                listHeader: Component {
                    CommHeader {
                        width: comm.width
                    }
                }
            }

            LogView {
                id: log1

                Layout.fillWidth: true
                Layout.fillHeight: true

                title: qsTr("Dashboard Log")

                portName: port1.currentText

                listDelegate: Component {
                    LogDelegate {
                        width: log1.width
                    }
                }

                listHeader: Component {
                    LogHeader {
                        width: log1.width
                    }
                }
            }

            LogView {
                id: log2

                Layout.fillWidth: true
                Layout.fillHeight: true

                title: qsTr("Back Control Log")

                portName: port2.currentText

                listDelegate: Component {
                    LogDelegate {
                        width: log2.width
                    }
                }

                listHeader: Component {
                    LogHeader {
                        width: log2.width
                    }
                }
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
                log1.appendLog(null, msg)
            } else {
                log2.appendLog(null, msg)
            }
        }

        onCommMessage: {
            var color = port1.currentText==targetPort ? backControlColor : dashboardColor
            comm.appendLog(color, targetPort, cmd, mod, value)
        }
    }
}
