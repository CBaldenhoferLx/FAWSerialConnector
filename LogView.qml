import QtQuick 2.11
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.4

Rectangle {

    readonly property int max_list_count: 5000
    property string portName
    property alias title: textTitle.text
    property alias showCmd: cmdPanel.visible
    property alias showExcludePing: excludePing.visible
    property alias showLogToFile: logToFile.visible

    property alias listDelegate: logListView.delegate
    property alias listHeader: logListView.header

    border.color: "black"
    border.width: 1

    function appendLog(color, p1, p2, p3, p4) {
        if (listModel.count>max_list_count) listModel.remove(0, 10);
        listModel.append({"c": color, "p1": p1, "p2": p2, "p3": p3, "p4": p4});
        logListView.positionViewAtEnd()
    }

    function clear() {
        listModel.clear()
    }

    ColumnLayout {
        anchors.fill: parent

        Text {
            id: textTitle

            Layout.fillWidth: true
            Layout.preferredHeight: 22

            horizontalAlignment: Text.Center

            font.bold: true
            font.pointSize: 14
        }

        Button {
            text: qsTr("Clear")

            Layout.fillWidth: true
            Layout.margins: 1
            Layout.preferredHeight: 26

            onClicked: clear()
        }

        ListView {
            id: logListView

            Layout.fillWidth: true
            Layout.fillHeight: true

            clip: true

            headerPositioning: ListView.OverlayHeader

            model: ListModel {
                id: listModel
            }
        }

        RowLayout {
            id: cmdPanel

            Layout.fillWidth: true
            Layout.preferredHeight: 30
            Layout.bottomMargin: 2
            Layout.rightMargin: 2

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 20
                Layout.leftMargin: 2

                border.color: "black"
                border.width: 1

                TextInput {
                    id: sendCmd
                    anchors.fill: parent

                    maximumLength: SerialConnector.cmdLength
                    cursorVisible: true
                    leftPadding: 2

                    onTextChanged: {
                        var tt = SerialConnector.generateTooltip(text);
                        if (tt) {
                            ToolTip.hide()
                            ToolTip.show(tt, 2000)
                        } else {
                            ToolTip.hide()
                        }
                    }

                    onAccepted: {
                        sendButton.clicked()
                    }
                }
            }

            Button {
                id: sendButton
                text: qsTr("Send")

                Layout.preferredHeight: 26

                enabled: SerialConnector.isConnected && sendCmd.length==SerialConnector.cmdLength

                onClicked: {
                    console.log("Sending cmd")
                    SerialConnector.sendCmd(portName, sendCmd.text)
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: false
            Layout.preferredHeight: excludePing.visible || logToFile.visible ? 50 : 0

            CheckBox {
                id: excludePing

                visible: false

                text: qsTr("Exclude Ping")

                checked: SerialConnector.excludePing

                onToggled: {
                    SerialConnector.excludePing = checked
                }
            }

            CheckBox {
                id: logToFile

                visible: false

                text: qsTr("Log To File")

                checked: SerialConnector.logToFile

                onToggled: {
                    SerialConnector.logToFile = checked
                }
            }
        }
    }

}
