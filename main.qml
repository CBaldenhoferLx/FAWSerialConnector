import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Layouts 1.3

Window {
    visible: true
    width: 1024
    height: 830
    title: qsTr("FAW Demo")

    property string dashboardColor: "beige"
    property string backControlColor: "honeydew"

    Component {
        id: commComp
        CommTab {
        }
    }

    Component {
        id: statusComp

        StatusTab {
        }
    }

    TabView {
        anchors.fill: parent

        Component.onCompleted: {
            addTab("Comm", commComp)
            currentIndex = 0
            addTab("Status", statusComp)
            currentIndex = 1
        }
    }
}
