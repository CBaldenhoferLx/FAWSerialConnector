import QtQuick 2.0
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.4

Item {

    property string portName
    property alias title: textTitle.text
    property alias showCmd: cmdPanel.visible
    property alias showExcludePing: excludePing.visible

    function appendLog(text) {
        textContent.append(text)
        //textContent.append("\n\r")
    }

    function clear() {
        textContent.clear()
    }

    ColumnLayout {
        anchors.fill: parent

        Text {
            id: textTitle

            Layout.fillWidth: true
            Layout.preferredHeight: 26

            font.bold: true
            font.pointSize: 18
        }

        Button {
            text: qsTr("Clear")

            Layout.fillWidth: true
            Layout.preferredHeight: 26

            onClicked: textContent.text = ""
        }

        ScrollView {
            id: textScrollView
            Layout.fillWidth: true
            Layout.fillHeight: true

            ScrollBar.horizontal.policy: ScrollBar.AsNeeded
            ScrollBar.vertical.policy: ScrollBar.AlwaysOn

            TextArea {
                id: textContent

                anchors.fill: parent

                wrapMode: TextEdit.NoWrap

                readOnly: true

                font.pointSize: 9

                onTextChanged: {
                }
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

                border.color: "black"
                border.width: 1

                TextInput {
                    id: sendCmd
                    anchors.fill: parent

                    maximumLength: SerialConnector.cmdLength

                    onTextChanged: {
                        var tt = SerialConnector.generateTooltip(text);
                        if (tt) ToolTip.show(tt, 2000)
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

        CheckBox {
            id: excludePing

            visible: false

            text: qsTr("Exclude Ping")

            checked: SerialConnector.excludePing

            onToggled: SerialConnector.excludePing = checked
        }
    }

}
