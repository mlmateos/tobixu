import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root
    anchors.fill: parent
    color: "#06281E"

    // Fondo Órbita Noche
    Image {
        anchors.fill: parent
        source: "orbita-noche.png"
        fillMode: Image.PreserveAspectCrop
    }

    // Glifo Xoo respirando
    Image {
        id: glifo
        source: "glifo-256.png"
        width: 200
        height: 112
        anchors.horizontalCenter: parent.horizontalCenter
        y: parent.height * 0.15
        
        SequentialAnimation on opacity {
            loops: Animation.Infinite
            NumberAnimation { to: 0.6; duration: 2000; easing.type: Easing.InOutSine }
            NumberAnimation { to: 1.0; duration: 2000; easing.type: Easing.InOutSine }
        }
    }

    // Tarjeta de Login Selva
    Rectangle {
        id: loginCard
        width: 400
        height: 450
        anchors.centerIn: parent
        color: "#CC0E4D3A" // Selva translúcido
        radius: 16
        border.width: 2
        border.color: "#8A2BE2" // Jacaranda
        
        Column {
            anchors.fill: parent
            anchors.margins: 30
            spacing: 20
            
            // Reloj y Fecha (Política de la puerta: en inglés, 24h)
            Column {
                width: parent.width
                spacing: 5
                
                Text {
                    id: clockText
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 56
                    font.weight: Font.Light
                    color: "white"
                    text: Qt.formatTime(new Date(), "HH:mm")
                    
                    Timer {
                        interval: 1000
                        running: true
                        repeat: true
                        onTriggered: clockText.text = Qt.formatTime(new Date(), "HH:mm")
                    }
                }
                
                Text {
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 16
                    color: "#E0E0E0"
                    property var enLocale: Qt.locale("en_US")
                    text: new Date().toLocaleDateString(enLocale, "dddd, d MMMM yyyy")
                }
            }
            
            Item { width: 1; height: 20 } // Espaciador
            
            // Campos de entrada
            Column {
                width: parent.width
                spacing: 15
                
                TextField {
                    id: userField
                    width: parent.width
                    placeholderText: "Username"
                    text: userModel.lastUser
                    color: "white"
                    font.pixelSize: 18
                    background: Rectangle {
                        radius: 8
                        color: "#33FFFFFF"
                        border.color: userField.focus ? "#8A2BE2" : "#FFFFFF"
                    }
                    Keys.onReturnPressed: loginButton.clicked()
                }
                
                TextField {
                    id: passField
                    width: parent.width
                    placeholderText: "Password"
                    echoMode: TextInput.Password
                    color: "white"
                    font.pixelSize: 18
                    background: Rectangle {
                        radius: 8
                        color: "#33FFFFFF"
                        border.color: passField.focus ? "#8A2BE2" : "#FFFFFF"
                    }
                    Keys.onReturnPressed: loginButton.clicked()
                }
                
                Button {
                    id: loginButton
                    width: parent.width
                    height: 50
                    text: "Sign in"
                    font.pixelSize: 18
                    font.weight: Font.Bold
                    background: Rectangle {
                        radius: 8
                        color: loginButton.down ? "#06281E" : "#0E4D3A"
                        border.color: "#8A2BE2"
                    }
                    contentItem: Text {
                        text: loginButton.text
                        font: loginButton.font
                        color: "white"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }
                    onClicked: {
                        // Fallback a 0 si lastIndex no está definido
                        var idx = (typeof sessionModel !== 'undefined' && sessionModel.lastIndex !== undefined) ? sessionModel.lastIndex : 0;
                        sddm.login(userField.text, passField.text, sessionBox.currentIndex);
                    }
                }
                ComboBox {
                    id: sessionBox
                    width: parent.width
                    model: sessionModel
                    textRole: "name"
                    currentIndex: sessionModel.lastIndex
                    background: Rectangle {
                        radius: 8
                        color: "#33FFFFFF"
                        border.color: sessionBox.activeFocus ? "#8A2BE2" : "#FFFFFF"
                    }
                    contentItem: Text {
                        text: sessionBox.currentText
                        color: "white"
                        font.pixelSize: 14
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                }
            }
        }
    }

    // Botones de apagado (Texto explícito, sin Repeater)
    Row {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 40
        spacing: 30
        
        Text {
            text: "Suspend"
            color: "white"
            font.pixelSize: 14
            visible: sddm.canSuspend
            MouseArea { 
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: sddm.suspend() 
            }
        }
        Text {
            text: "Restart"
            color: "white"
            font.pixelSize: 14
            visible: sddm.canReboot
            MouseArea { 
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: sddm.reboot() 
            }
        }
        Text {
            text: "Shut Down"
            color: "white"
            font.pixelSize: 14
            visible: sddm.canPowerOff
            MouseArea { 
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: sddm.powerOff() 
            }
        }
    }
    
    // Manejo de foco inicial
    Component.onCompleted: {
        if (userField.text !== "") {
            passField.forceActiveFocus();
        } else {
            userField.forceActiveFocus();
        }
    }
}
