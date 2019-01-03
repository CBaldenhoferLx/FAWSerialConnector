import QtQuick 2.11
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.4

Item {
    anchors.fill: parent

    Connections {
        target: SerialConnector

        onRawMessage: {
            console.log("New comm");
            console.log(cmd, mod, value)

            var CMD_PING = 'p';
            var CMD_PING_FB = 'P';
            var CMD_VAPO = 'v';
            var CMD_VAPO_FB = 'V';
            var CMD_MM_FB = 'M';
            var CMD_FAN = 'f';
            var CMD_FAN_FB = 'F';
            var CMD_SEAT = 's';
            var CMD_SEAT_POS_FB = 'S';
            var CMD_SEAT_SWITCH_FB = 'W';
            var CMD_SEAT_MOVE_FB = 'O';
            var CMD_LEVEL_FB = 'L';
            var CMD_LED_COLOR = 'e';
            var CMD_LED_COLOR_FB = 'E';
            var CMD_LED_BRIGHTNESS = 'b';
            var CMD_LED_BRIGHTNESS_FB = 'B';

            switch(cmd) {
            case CMD_VAPO_FB:
                break;
            case CMD_MM_FB:
                vapo.setVapo(mod, value)
                break;
            case CMD_FAN_FB:
                fan.strength = value;
                break;
            case CMD_SEAT_POS_FB:
                break;
            case CMD_SEAT_SWITCH_FB:
                varHolder.setSwitch(mod, value);
                break;
            case CMD_SEAT_MOVE_FB:
                varHolder.setMove(mod, value);
                break;
            case CMD_LEVEL_FB:
                vapo.setLevel(mod, value)
                break;
            case CMD_LED_COLOR_FB:
                varHolder.setColor(mod, value);
                break;
            case CMD_LED_BRIGHTNESS_FB:
                varHolder.setBrightness(mod, value);
                break;
            }
        }
    }

    Image {
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        height: 800

        source: "model.png"
        scale: Image.PreserveAspectFit

        verticalAlignment: Image.AlignVCenter
        horizontalAlignment: Image.AlignHCenter

        MouseArea {
            anchors.fill: parent

            onClicked: {
                console.log(mouse.x, " ", mouse.y)
            }
        }

        QtObject {
            id: varHolder

            readonly property color defaultColor: "transparent"

            function resolveArrowComponent(mod) {
                var MOD_FORWARD = 'f'
                var MOD_BACKWARD = 'b'

                switch(mod) {
                case MOD_FORWARD: return forwardSwitch;
                case MOD_BACKWARD: return backwardSwitch;
                default:
                    console.warn("Unknown component", mod);
                }

            }

            function resolveLedComponent(mod) {
                var MOD_LED_DASHBOARD = 'd'
                var MOD_LED_FINS = 'f'
                var MOD_LED_CABLE_HOLDER = 'c'
                var MOD_LED_HEADLIGHTS = 'h'
                var MOD_LED_HEADLIGHTS_AMB = 'a'
                var MOD_LED_MIDDLE_STRIP = 'm'

                switch(mod) {
                case MOD_LED_DASHBOARD: return dashboardLed;
                case MOD_LED_FINS: return finsLed;
                case MOD_LED_CABLE_HOLDER: return cableHolderLed;
                case MOD_LED_HEADLIGHTS: return headlightsLed;
                case MOD_LED_HEADLIGHTS_AMB: return headlightsAmbLed;
                case MOD_LED_MIDDLE_STRIP: return middleStripLed;
                default:
                    console.warn("Component not found", mod)
                }
            }

            function setMove(mod, raw) {
                if (raw==='1') {
                    forwardSwitch.moveActive = true
                    backwardSwitch.moveActive = false
                } else if (raw==='2') {
                    forwardSwitch.moveActive = false
                    backwardSwitch.moveActive = true
                } else {
                    forwardSwitch.moveActive = false
                    backwardSwitch.moveActive = false
                }
            }

            function setSwitch(mod, raw) {
                var comp = resolveArrowComponent(mod);
                comp.switchActive = raw==='1'
            }

            function setColor(mod, raw) {
                var comp = resolveLedComponent(mod);

                comp.color = resolveColor(raw);

                console.log("Color", comp, comp.color);
            }

            function setBrightness(mod, raw) {
                var comp = resolveLedComponent(mod);

                comp.itemBrightness = raw;
            }

            function resolveColor(raw) {
                switch(parseInt(raw)) {
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

        LedSpot {
            id: dashboardLed
            x: 216
            y: 422

            identifier: 'd'

            color: varHolder.defaultColor
        }

        LedSpot {
            id: headlightsLed
            x: 313
            y: 610

            identifier: 'h'

            color: varHolder.defaultColor
        }

        LedSpot {
            id: headlightsAmbLed
            x: 371
            y: 585

            identifier: 'a'

            color: varHolder.defaultColor
        }

        LedSpot {
            id: middleStripLed
            x: 181
            y: 590

            identifier: 'm'

            color: varHolder.defaultColor
        }

        LedSpot {
            id: finsLed
            x: 369
            y: 384

            identifier: 'f'

            color: varHolder.defaultColor
        }

        LedSpot {
            id: cableHolderLed
            x: 261
            y: 24

            identifier: 'c'

            color: varHolder.defaultColor
        }

        ArrowSpot {
            id: forwardSwitch

            x: 370
            y: 200

            rotation: 10

            switchActive: false
            moveActive: false

            onTriggered: {
                if (moveActive) {
                    SerialConnector.sendCmd(2, "ss0")
                } else {
                    SerialConnector.sendCmd(2, "sf0")
                }
            }
        }

        ArrowSpot {
            id: backwardSwitch

            x: 414
            y: 360

            rotation: 190

            switchActive: false
            moveActive: false

            onTriggered: {
                if (moveActive) {
                    SerialConnector.sendCmd(2, "ss0")
                } else {
                    SerialConnector.sendCmd(2, "sb0")
                }
            }
        }

        FanSpot {
            id: fan

            x: 319
            y: 481
        }

        Row {
            x: 195
            y: 525

            spacing: 4

            Repeater {
                id: vapo

                function resolveMod(mod) {
                    var MOD_LEFT = 'l';
                    var MOD_MIDDLE = 'm';
                    var MOD_RIGHT = 'r';


                    switch(mod) {
                    case MOD_LEFT: return 0;
                    case MOD_MIDDLE: return 1;
                    case MOD_RIGHT: return 2;
                    default:
                        console.warn("Unknown mod", mod);
                    }
                }

                function setVapo(mod, value) {
                    var index = resolveMod(mod);
                    itemAt(index).isActive = value==1
                }

                function setLevel(mod, value) {
                    var index = resolveMod(mod);
                    itemAt(index).level = value
                }

                model: 3

                VapoSpot {
                    identifier: index==0 ? "l" : index==1 ? "m" : "r"
                }
            }
        }
    }
}
