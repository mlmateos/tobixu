import QtQuick 2.15

Item {
    id: root
    Image {
        anchors.fill: parent
        source: "images/orbita-noche.png"
        fillMode: Image.PreserveAspectCrop
    }
    Image {
        anchors.centerIn: parent
        source: "images/glifo-256.png"
    }
}
