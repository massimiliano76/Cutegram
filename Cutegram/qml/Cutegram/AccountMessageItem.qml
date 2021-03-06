import QtQuick 2.0
import AsemanTools.Controls 1.0
import AsemanTools 1.0
import Cutegram 1.0
import CutegramTypes 1.0
import QtGraphicalEffects 1.0

Item {
    id: msg_item
    width: 100
    height: logicalHeight<minimumHeight? minimumHeight : logicalHeight
    clip: true

    property real messageFrameX: back_rect.x
    property real messageFrameY: back_rect.y
    property real messageFrameWidth: back_rect.width
    property real messageFrameHeight: back_rect.height

    property real logicalHeight: action_item.hasAction? action_item.height: column.height + frameMargins*2 + textMargins*2
    property real minimumHeight: 48*Devices.density
    property real maximumWidth: 2*width/3

    property alias maximumMediaHeight: msg_media.maximumMediaHeight
    property alias maximumMediaWidth: msg_media.maximumMediaWidth

    property bool visibleNames: true

    property Message message
    property User user: telegramObject.user(message.fromId)
    property User fwdUser: telegramObject.user(message.fwdFromId)

    property real minimumWidth: 100*Devices.density
    property real textMargins: 4*Devices.density
    property real frameMargins: 4*Devices.density

    property bool sent: message.sent
    property bool uploading: message.upload.fileId != 0

    property alias hasMedia: msg_media.hasMedia
    property bool encryptMedia: message.message.length==0 && message.encrypted
    property alias mediaLOcation: msg_media.locationObj

    property alias selectedText: msg_txt.selectedText
    property alias messageRect: back_rect

    property bool modernMode: false

    signal dialogRequest(variant dialogObject)

    onSentChanged: {
        if( sent )
            indicator.stop()
        else
            indicator.start()
    }

    AccountMessageAction {
        id: action_item
        anchors.left: parent.left
        anchors.right: parent.right
        message: msg_item.message
    }

    Row {
        id: frame_row
        anchors.fill: parent
        layoutDirection: message.out? Qt.RightToLeft : Qt.LeftToRight
        visible: !action_item.hasAction
        spacing: frameMargins

        Frame {
            anchors.verticalCenter: parent.verticalCenter
            width: 40*Devices.density
            height: width
            backgroundColor: "#E4E9EC"

            ContactImage {
                id: img
                anchors.fill: parent
                user: msg_item.user
                isChat: false
                circleMode: false

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: msg_item.dialogRequest( telegramObject.fakeDialogObject(img.user.id, false) )
                }
            }
        }

        Frame {
            anchors.verticalCenter: parent.verticalCenter
            width: img.width
            height: img.height
            visible: message.fwdFromId != 0
            backgroundColor: "#E4E9EC"

            ContactImage {
                id: forward_img
                anchors.fill: parent
                user: msg_item.fwdUser
                isChat: false
                circleMode: false

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: msg_item.dialogRequest( telegramObject.fakeDialogObject(forward_img.user.id, false) )
                }
            }
        }

        Item {
            id: spacer
            height: 10
            visible: modernMode
            width: parent.width/2 - (forward_img.width+frameMargins)*forward_img.visible
                   - (img.width+frameMargins) - back_rect.width/2
        }

        Item {
            height: 10
            width: 10*Devices.density
        }

        Item {
            id: back_rect
            width: column.width + 2*textMargins
            height: column.height + 2*textMargins
            anchors.verticalCenter: parent.verticalCenter

            Item {
                id: msg_frame_box
                anchors.fill: parent
                anchors.margins: -20*Devices.density
                visible: !Cutegram.currentTheme.messageShadow

                Item {
                    anchors.fill: parent
                    anchors.margins: 20*Devices.density

                    Rectangle {
                        id: pointer_rect
                        height: Cutegram.currentTheme.messagePointerHeight*Devices.density
                        width: height
                        anchors.horizontalCenter: message.out? parent.right : parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        color: back_rect_layer.color
                        transformOrigin: Item.Center
                        rotation: 45
                    }

                    Rectangle {
                        id: back_rect_layer
                        anchors.fill: parent
                        radius: Cutegram.currentTheme.messageRadius*Devices.density
                        color: {
                            if(hasMedia || encryptMedia)
                                return Cutegram.currentTheme.messageMediaColor
                            else
                            if(message.out)
                                return Cutegram.currentTheme.messageOutgoingColor
                            else
                                return Cutegram.currentTheme.messageIncomingColor
                        }
                    }
                }
            }

            DropShadow {
                anchors.fill: source
                source: msg_frame_box
                radius: Cutegram.currentTheme.messageShadowSize*Devices.density
                samples: 16
                horizontalOffset: 0
                verticalOffset: 1*Devices.density
                visible: Cutegram.currentTheme.messageShadow
                color: Cutegram.currentTheme.messageShadowColor
            }

            Column {
                id: column
                anchors.centerIn: parent
                height: (visibleNames?user_name.height:0) + (uploading?uploadItem.height:0) + (msg_media.hasMedia?msg_media.height:0) + spacing + msg_column.height
                clip: true

                Text {
                    id: user_name
                    font.pixelSize: Math.floor(11*Devices.fontDensity)
                    font.family: AsemanApp.globalFont.family
                    lineHeight: 1.3
                    text: user.firstName + " " + user.lastName
                    visible: visibleNames
                    color: {
                        if(hasMedia || encryptMedia)
                            return Cutegram.currentTheme.messageMediaNameColor
                        else
                        if(message.out)
                            return Cutegram.currentTheme.messageOutgoingNameColor
                        else
                            return Cutegram.currentTheme.messageIncomingNameColor
                    }
                }

                AccountMessageUpload {
                    id: uploadItem
                    telegram: telegramObject
                    message: msg_item.message
                }

                AccountMessageMedia {
                    id: msg_media
                    media: message.media
                    visible: msg_media.hasMedia && !uploading
                }

                Column {
                    id: msg_column
                    anchors.right: parent.right

                    Item {
                        id: msg_txt_frame
                        width: msg_txt.width + 8*Devices.density
                        height: msg_txt.height + 8*Devices.density
                        visible: !msg_media.hasMedia && !uploading

                        TextEdit {
                            id: msg_txt
                            width: htmlWidth>maximumWidth? maximumWidth : htmlWidth
                            anchors.centerIn: parent
                            font.pixelSize: Math.floor(Cutegram.font.pointSize*Devices.fontDensity)
                            font.family: Cutegram.font.family
                            persistentSelection: true
                            activeFocusOnPress: false
                            selectByMouse: true
                            readOnly: true
                            selectionColor: masterPalette.highlight
                            selectedTextColor: masterPalette.highlightedText
                            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                            text: emojis.bodyTextToEmojiText(messageText)
                            textFormat: Text.RichText
                            height: contentHeight
                            onLinkActivated: Qt.openUrlExternally(link)
                            color: {
                                if(hasMedia || encryptMedia)
                                    return Cutegram.currentTheme.messageMediaDateColor
                                else
                                if(message.out)
                                    return Cutegram.currentTheme.messageOutgoingFontColor
                                else
                                    return Cutegram.currentTheme.messageIncomingFontColor
                            }

                            property real htmlWidth: Cutegram.htmlWidth(text)
                            property string messageText: encryptMedia? qsTr("Media files is not supported on secret chat currently") : message.message
                        }
                    }

                    Row {
                        anchors.right: parent.right
                        spacing: 4*Devices.density

                        Text {
                            id: time_txt
                            font.family: AsemanApp.globalFont.family
                            font.pixelSize: Math.floor(9*Devices.fontDensity)
                            text: Cutegram.getTimeString(msgDate)
                            verticalAlignment: Text.AlignVCenter
                            color: {
                                if(hasMedia || encryptMedia)
                                    return Cutegram.currentTheme.messageMediaDateColor
                                else
                                if(message.out)
                                    return Cutegram.currentTheme.messageOutgoingDateColor
                                else
                                    return Cutegram.currentTheme.messageIncomingDateColor
                            }

                            property variant msgDate: CalendarConv.fromTime_t(message.date)
                        }

                        Item {
                            id: state_indict
                            width: 12*Devices.density
                            height: 8*Devices.density
                            visible: message.out
                            anchors.verticalCenter: parent.verticalCenter

                            Image {
                                id: seen_indict
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                width: 8*Devices.density
                                height: width
                                visible: !message.unread && message.out
                                sourceSize: Qt.size(width,height)
                                source: indicator.light? "files/sent-light.png" : "files/sent.png"
                            }

                            Image {
                                id: sent_indict
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.right: parent.right
                                width: 8*Devices.density
                                height: width
                                visible: message.sent && message.out
                                sourceSize: Qt.size(width,height)
                                source: indicator.light? "files/sent-light.png" : "files/sent.png"
                            }

                            Indicator {
                                id: indicator
                                anchors.centerIn: parent
                                modern: true
                                indicatorSize: 10*Devices.density
                                Component.onCompleted: if(!sent) start()
                                light: {
                                    if(hasMedia || encryptMedia) {
                                        return Cutegram.currentTheme.messageMediaLightIcon
                                    } else if(message.out) {
                                        return Cutegram.currentTheme.messageOutgoingLightIcon
                                    } else {
                                        return Cutegram.currentTheme.messageIncomingLightIcon
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    function click() {
        msg_media.click()
    }

    function copy() {
        if(hasMedia)
            Devices.clipboardUrl = [msg_media.locationObj.download.location]
        else
        if(msg_txt.selectedText.length == 0)
            Devices.clipboard = message.message
        else
            msg_txt.copy()
    }

    function discardSelection() {
        msg_txt.deselect()
    }
}
