import QtQuick 2.0
import AsemanTools 1.0
import Cutegram 1.0
import CutegramTypes 1.0
import QtGraphicalEffects 1.0

Item {
    id: msg_box
    width: 100
    height: 62

    property Telegram telegramObject
    property Dialog currentDialog: telegramObject.nullDialog

    property alias maxId: messages.maxId

    Item {
        id: properties_frame
        anchors.left: parent.left
        anchors.right: parent.right
        height: parent.height
        clip: true
    }

    Item {
        id: message_box
        width: parent.width
        height: parent.height
        y: header.properties && header.properties.inited? header.properties.height : 0
        clip: true

        Behavior on y {
            NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
        }

        AccountMessageList {
            id: messages
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            topMargin: header.height
            bottomMargin: send_msg.height
            telegramObject: msg_box.telegramObject
            currentDialog: msg_box.currentDialog
            onForwardRequest: forward_component.createObject(message_box, {"forwardMessage":message})
            onFocusRequest: send_msg.setFocus()
            onDialogRequest: acc_view.currentDialog = dialogObject
        }

        Item {
            id: header_blur
            anchors.fill: header
            clip: true
            visible: Cutegram.currentTheme.visualEffects

            FastBlur {
                anchors.top: parent.top
                width: messages.width
                height: messages.height
                source: messages
                radius: Cutegram.currentTheme.visualEffects?64:0
            }
        }

        Item {
            id: send_msg_blur
            anchors.fill: send_msg
            clip: true
            visible: Cutegram.currentTheme.visualEffects

            FastBlur {
                anchors.bottom: parent.bottom
                width: messages.width
                height: messages.height
                source: messages
                radius: Cutegram.currentTheme.visualEffects?64:0
            }
        }

        AccountDialogHeader {
            id: header
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.right: parent.right
            currentDialog: msg_box.currentDialog
            refreshing: messages.refreshing
            color: {
                if(currentDialog.encrypted)
                    return Cutegram.currentTheme.headerSecretColor
                else
                    return Cutegram.currentTheme.headerColor
            }
            onClicked: {
                if( properties )
                    properties.end()
                else
                if( currentDialog != telegramObject.nullDialog )
                    properties = user_prp_component.createObject(properties_frame)
            }

            property UserProperties properties
        }

        AccountSendMessage {
            id: send_msg
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            color: Cutegram.currentTheme.sendFrameColor
            currentDialog: msg_box.currentDialog
            onAccepted: messages.sendMessage(text)
            trash: messages.messageDraging
            onCopyRequest: messages.copy()
            onEmojiRequest: {
                var item = emoticons_component.createObject(message_box)
                var w = 260*Devices.density
                var h = w

                var newPoint = msg_box.mapFromItem(send_msg, x, y)
                var nx = newPoint.x
                var ny = newPoint.y

                point_dialog.pointerLeftMargin = w*0.6
                point_dialog.item = item
                point_dialog.pointingTo(nx-w*0.6-20*Devices.density, ny, w, h)
            }
        }

        Item {
            id: drop_file_blur
            anchors.fill: drop_file
            clip: true
            opacity: drop_file.visibleRatio
            visible: opacity != 0 && Cutegram.currentTheme.visualEffects

            FastBlur {
                anchors.top: parent.top
                anchors.topMargin: -messages.topMargin
                width: messages.width
                height: messages.height
                source: messages
                radius: Cutegram.currentTheme.visualEffects?32:0
            }
        }

        DialogDropFile {
            id: drop_file
            anchors.left: parent.left
            anchors.top: header.bottom
            anchors.right: parent.right
            anchors.bottom: send_msg.top
            dialogItem: msg_box.currentDialog
            currentDialog: msg_box.currentDialog
        }

        Rectangle {
            anchors.fill: parent
            color: "#ffffff"
            opacity: header.properties && header.properties.inited? 0.5 : 0
            visible: header.properties? true : false

            Behavior on opacity {
                NumberAnimation{ easing.type: Easing.OutCubic; duration: 400 }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.RightButton | Qt.LeftButton
                hoverEnabled: true
                onWheel: wheel.accepted = true
                onClicked: BackHandler.back()
            }
        }
    }

    PointingDialog{
        id: point_dialog
        z: 9
    }

    Component {
        id: emoticons_component
        Emoticons {
            id: emoticons
            anchors.right: parent.right
            anchors.bottom: send_msg.top
            anchors.top: header.bottom
            width: 200*Devices.density
            onSelected: send_msg.insertText(code)
        }
    }

    Component {
        id: user_prp_component
        UserProperties {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.right: parent.right
            currentDialog: messages.currentDialog
            color: Desktop.titleBarColor
            onAddParticianRequest: {
                acc_view.addParticianRequest()
            }
        }
    }

    Component {
        id: forward_component
        Item {
            id: forward_item
            anchors.fill: messages
            clip: true

            property alias forwardMessage: forward_page.forwardMessage
            property alias forwardDialog: forward_page.forwardDialog

            FastBlur {
                anchors.fill: parent
                source: messages
                radius: Cutegram.currentTheme.visualEffects?64:0
                visible: Cutegram.currentTheme.visualEffects
            }

            ForwardPage {
                id: forward_page
                anchors.fill: parent
                color: Cutegram.currentTheme.visualEffects?"#66ffffff":"#ddffffff"
                onCloseRequest: forward_item.destroy()
            }

            Connections {
                target: acc_view
                onCurrentDialogChanged: forwardDialog = acc_view.currentDialog
            }
        }
    }

    function focusOn(msgId) {
        messages.focusOn(msgId)
    }
}

