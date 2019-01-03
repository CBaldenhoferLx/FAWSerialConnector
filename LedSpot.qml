import QtQuick 2.0
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.3

Rectangle {
    id: root
    property alias itemBrightness: brightnessValue.text
    property string identifier

    width: 60
    height: 60

    color: "transparent"

    radius: 360

    border.color: "black"
    border.width: 2

    MouseArea {
        anchors.fill: parent

        onClicked: {
            popup.open()
        }
    }

    Text {
        id: brightnessValue

        anchors.centerIn: parent
        text: "n/a"
    }

    Popup {
        id: popup
        width: 250
        height: 200
        modal: true
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

        QtObject {
            id: helperObj

            function resolveColor(index) {
                switch(index) {
                case 0: return "transparent";
                case 1: return "#FF0000";
                case 2: return "#FF1493";
                case 3: return "#800080";
                case 4: return "#4169E1";
                case 5: return "#00BFFF";
                case 6: return "#90EE90";
                case 7: return "#FFD700";
                case 8: return "#FFA500";
                case 9: return "#F8F8FF";
                default:
                    console.warn("Unknown color", raw);
                }
            }
        }

        ColumnLayout {
            RowLayout {
                Repeater {
                    model: 9

                    Rectangle {
                        height: 20
                        width: 20

                        border.color: "black"
                        border.width: 1

                        color: helperObj.resolveColor(index)

                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                SerialConnector.sendCmd(0, "e" + identifier + index);
                            }
                        }
                    }
                }
            }

            SpinBox {
                from: 0
                to: 9

                value: parseInt(brightnessValue.text)

                onValueModified: {
                    SerialConnector.sendCmd(0, "b" + identifier + value);
                }
            }
        }
    }
}

