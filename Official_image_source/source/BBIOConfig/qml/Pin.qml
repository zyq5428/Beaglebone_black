/*****************************************************************************
    Copyright (c) 2014 Alexander Rössler <mail.aroessler@gmail.com>

    This file is part of BBPinConfig.

    BBIOConfig is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    BBIOConfig is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with BBIOConfig.  If not, see <http://www.gnu.org/licenses/>.

 *****************************************************************************/
import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import "Functions.js" as Functions

Item {
    property string defaultFunction: "GPIO"                                             // function when cape is not loded
    property var    functions: ["GPIO", "I2C", "UART"]                                  // pinmux functions
    property var    info: ["gpio1_0", "gpio1_0", "i2c1_cs", "uart0_sck"]                // info to default function and pinmux functions
    property string type: "GPIO"                                                        // current selected type
    property var    overlay: ["cape-test"]                                              // overlay that is necessary for pinmuxing
    property var    loadedOverlays: ["cape-test", "cape-test2"]                         // currently loaded overlay
    property bool   pinmuxActive: getPinmuxActive()                                     // determines wheter the pinmux is active or not
    property string previewType: ""                                                     // type for preview mode
    property string previewOverlay: ""                                                  // overlay for preview mode
    property bool   previewEnabled: false                                               // enabled the preview mdoe
    property bool   previewActive:  getPreviewActive()                                  // holds whether the preview is active or not
    property string gpioDirection: "unmodified"                                         // type of the gpio pin (in or out)
    property var    gpioDirections: ["unmodified", "in", "out"]
    property string gpioValue: "unmodified"                                             // startup gpio value
    property var    gpioValues: ["unmodifed", "low", "high"]
    property int    pinNumber: 0                                                        // number of the pin
    property int    portNumber: 0
    property int    pruPinNumber: 0
    property int    kernelPinNumber: 0
    property var    colorMap: [["GPIO", "red"], ["I2C", "blue"], ["UART", "green"]]     // current avtive color map
    property alias  numberVisible: numberText.visible                                   // visibility of the number
    property string description: "Test"                                                 // descriptive text for the pin
    property bool   editable: getEditable()                                             // editability of the pin
    property alias  textInput: descriptionTextInput                                     // currently active text input
    property string infoText: getInfoText()                                             // info text for the pin
    property int    configMode: 0                                                       // active config mode: 0=function, 1=gpio dir, 2=gpio value
    property double uneditableOpacitiy: (configMode == 0)?(displayUneditablePins?1.0:0.1):0.2
    property bool   rightSide: ((main.pinNumber % 2) == 0)

    property bool displayUneditablePins: true

    signal previewEntered(string type)
    signal previewExited()
    signal dataChangedUnfiltered()
    signal dataChanged()

    Component.onCompleted: {
        onTypeChanged.connect(dataChangedUnfiltered)
        onGpioDirectionChanged.connect(dataChangedUnfiltered)
        onGpioValueChanged.connect(dataChangedUnfiltered)
        textInput.onTextChanged.connect(dataChangedUnfiltered)
    }

    onDataChangedUnfiltered: {
        if ((pinNumber != 0) && (portNumber != 0))  // this fixed the wrong behaviour when config mode is switched
            dataChanged()
    }
    
    function getPinmuxActive() {
        var overlayActive = false
        for (var i = 0; i < overlay.length; ++i) {
            if (overlay[i] === "") {
                continue
            }

            if (loadedOverlays.indexOf(overlay[i]) !== -1) {
                overlayActive = true
                break
            }
        }

        return (overlayActive) && ((functions.length > 0) && (functions[0] !== "reserved"))
    }

    function getEditable() {
        switch (configMode) {
        case 0: return pinmuxActive
        case 1: return ((type === "gpio") || (type === "gpio_pu") || (type === "gpio_pd"))
        case 2: return (((type === "gpio") || (type === "gpio_pu") || (type === "gpio_pd")) && (gpioDirection === "out"))
        default: return false
        }
    }

    function getInfoText() {
        var functionIndex = functions.indexOf((previewActive?previewType:type))
        if (!pinmuxActive && !previewActive)
            return info[0]

        if ((previewActive) && previewType == defaultFunction)
            return info[0]

        if ((functionIndex != -1) && (info.length > (functionIndex+1))) {
            return info[functionIndex+1]
        }
        else {
            return ""
        }
    }

    function getColor() {
        var searchValue

        if (main.configMode == 1) {
            searchValue = main.gpioDirection
        }
        else if (main.configMode == 2) {
            searchValue = main.gpioValue
        }
        else if (main.previewActive) {
            if (main.previewType != "")
                searchValue = main.previewType
            else if (overlayPreviewTimer.x)     // previewing an overlay -> blinking
                 return "white"
            else
                searchValue = main.defaultFunction
        }
        else if (main.pinmuxActive) {
            searchValue = main.type
        }
        else {
            searchValue = main.defaultFunction
        }

        for (var i = 0; i < main.colorMap.length; ++i)
        {
            if (main.colorMap[i][0] === searchValue)
            {
                return main.colorMap[i][1]
            }
        }
        return "grey"
    }

    function getPreviewActive() {

        if (previewEnabled && (previewType == "") && (overlay.indexOf(previewOverlay) != -1))
            return true

        if ((!previewEnabled) || (previewType == ""))
            return false

        if (previewType === defaultFunction)
            return true

        if (functions.indexOf(previewType) != -1)
            return true;

        return false;
    }

    id: main
    width: 100
    height: 62

    Timer {
        property color previewColor: "white"
        property bool x: true
        id: overlayPreviewTimer
        interval: 400
        running: previewActive && (previewOverlay != "")
        repeat: true
        onTriggered: x = !x
    }

    ToolTip {
        anchors.left: rightSide?parent.right:undefined
        anchors.leftMargin: parent.width*0.8
        anchors.right: !rightSide?parent.left:undefined
        anchors.rightMargin: anchors.leftMargin
        width: childrenRect.width + main.width
        height: childrenRect.height + main.width
        color: "white"
        border.color: "black"

        visible: (comboBox.hovered || comboBox2.hovered || comboBox3.hovered || mouseArea.containsMouse) && !(previewEnabled && (previewType == ""))
        z: 1000

        Text {
            x: main.width/2
            y: main.width/2
            font.pixelSize: 0
            text: "<b>P" + portNumber + "_" + pinNumber + "</b><br>" +
                  infoText + " (" + (pinmuxActive?type:defaultFunction) + ")" +
                  ((kernelPinNumber != 0)?"<br>" + qsTr("Kernel Pin: ") + kernelPinNumber:"") +
                  ((pruPinNumber != 0)?"<br>" + qsTr("PRU Pin: ") + pruPinNumber:"")
        }
    }

    Rectangle {
        id: pinRect
        anchors.fill: parent
        color: getColor()
        opacity: (editable || previewActive || (previewEnabled && previewType == ""))?1.0:uneditableOpacitiy
    }

    Text {
        id: numberText
        anchors.fill: parent
        color: ((pinRect.opacity > 0.5) && (pinRect.color.r+pinRect.color.g+pinRect.color.b) < 2.0)?"white":"black"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: main.pinNumber
        font.bold: true
        font.pixelSize: parent.width*0.6
    }

    ComboBox {
        id: comboBox
        anchors.fill: parent
        model: main.functions
        style: ComboBoxStyle {
            background: Item {}
            label: Item {}
        }
        visible: (main.editable && (main.configMode == 0))

        Binding { target: main; property: "type"; value: comboBox.currentText}
        //Binding { target: comboBox; property: "currentText"; value: main.type}    // This binding does not do what it should do
        Timer {                                                                     // and this is the reason for this timer
            repeat: true                                                            // updating the index of the combo box
            interval: 100
            running: parent.visible
            onTriggered: {
                if (parent.currentText !== main.type)
                    parent.currentIndex = parent.model.indexOf(main.type)
            }
        }

        Keys.onPressed: {
            if ((event.key === Qt.Key_Menu) || (event.key === Qt.Key_Tab) || (event.key === Qt.Key_Return)) {
                textInput.forceActiveFocus()
            }
        }
    }

    ComboBox {
        id: comboBox2
        anchors.fill: parent
        model: main.gpioDirections
        style: ComboBoxStyle {
            background: Item {}
            label: Item {}
        }
        visible: (main.editable && (main.configMode == 1))

        Binding { target: main; property: "gpioDirection"; value: comboBox2.currentText}
        //Binding { target: comboBox2; property: "currentText"; value: main.gpioDirection}  // This binding does not do what it should do
        Timer {                                                                             // and this is the reason for this timer
            repeat: true                                                                    // updating the index of the combo box
            interval: 100
            running: parent.visible
            onTriggered: {
                if (parent.currentText !== main.gpioDirection)
                    parent.currentIndex = parent.model.indexOf(main.gpioDirection)
            }
        }

        Keys.onPressed: {
            if ((event.key === Qt.Key_Menu) || (event.key === Qt.Key_Tab) || (event.key === Qt.Key_Return)) {
                textInput.forceActiveFocus()
            }
        }
    }

    ComboBox {
        id: comboBox3
        anchors.fill: parent
        model: main.gpioValues
        style: ComboBoxStyle {
            background: Item {}
            label: Item {}
        }
        visible: (main.editable && (main.configMode == 2))

        Binding { target: main; property: "gpioValue"; value: comboBox3.currentText}
        //Binding { target: comboBox3; property: "currentText"; value: main.gpioValue}      // This binding does not do what it should do
        Timer {                                                                             // and this is the reason for this timer
            repeat: true                                                                    // updating the index of the combo box
            interval: 100
            running: parent.visible
            onTriggered: {
                if (parent.currentText !== main.gpioValue)
                    parent.currentIndex = parent.model.indexOf(main.gpioValue)
            }
        }

        Keys.onPressed: {
            if ((event.key === Qt.Key_Menu) || (event.key === Qt.Key_Tab) || (event.key === Qt.Key_Return)) {
                textInput.forceActiveFocus()
            }
        }
    }

    TextInput {
        id: descriptionTextInput
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: rightSide ? parent.right : undefined
        anchors.leftMargin:  parent.width * 0.8
        anchors.right: rightSide ? undefined : parent.left
        anchors.rightMargin: anchors.leftMargin
        width: parent.width*8
        horizontalAlignment: rightSide ? TextInput.AlignLeft : TextInput.AlignRight
        font.pixelSize: parent.width*0.9
        visible: !previewActive
        readOnly: !main.editable
        selectByMouse: true

        MouseArea {
            anchors.fill: parent
            cursorShape: main.editable? Qt.IBeamCursor: Qt.ArrowCursor
            enabled: false
        }

        Binding { target: main; property: "description"; value: descriptionTextInput.text }
        Binding { target: descriptionTextInput; property: "text"; value: main.description }

        Keys.onPressed: {
            if ((event.key === Qt.Key_Menu) || (event.key === Qt.Key_Return)) {
                var target
                switch (main.configMode) {
                case 0: target = comboBox; break;
                case 1: target = comboBox2; break;
                case 2: target = comboBox3; break;
                }
                target.forceActiveFocus()
            }
        }
    }

    Text {
        id: descriptionInfoText
        anchors.verticalCenter: descriptionTextInput.verticalCenter
        anchors.left: rightSide ? descriptionTextInput.left : undefined
        anchors.right: rightSide ? undefined : descriptionTextInput.right
        width: descriptionTextInput.width
        horizontalAlignment: descriptionTextInput.horizontalAlignment
        font: descriptionTextInput.font
        visible: previewActive
        text: main.infoText
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: main.editable? Qt.PointingHandCursor: Qt.ArrowCursor
        enabled: (previewEnabled && (previewType == "")) || !editable
        hoverEnabled: enabled
        onHoveredChanged: {
            if (containsMouse)
            {
                previewEntered(main.type)
            }
            else
            {
                previewExited()
            }
        }
    }
}
