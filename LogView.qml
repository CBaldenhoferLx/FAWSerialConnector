import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.4

Item {

    property string portName
    property alias title: textTitle.text
    property alias content: textContent.text
    property alias showCmd: cmdPanel.visible

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

        TextArea {
            id: textContent

            wrapMode: TextEdit.NoWrap

            readOnly: true

            Layout.fillWidth: true
            Layout.fillHeight: true

            font.pointSize: 9
        }

        RowLayout {
            id: cmdPanel

            Layout.fillWidth: true
            Layout.preferredHeight: 26

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
                }
            }

            Button {
                text: qsTr("Send")

                enabled: /*SerialConnector.isConnected &&*/ sendCmd.length==SerialConnector.cmdLength

                onClicked: {
                    SerialConnector.sendCmd(portName, sendCmd.text)
                }
            }
        }
    }

}
