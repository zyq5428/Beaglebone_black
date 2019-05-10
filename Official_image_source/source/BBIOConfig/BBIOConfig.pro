TEMPLATE = app
TARGET = bbioconfig

QT += qml quick widgets
QT -= network

SOURCES += main.cpp \
    fileio.cpp

HEADERS += \
    fileio.h

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

windows: {
    RC_FILE = icon.rc
}

macx: {
    QMAKE_INFO_PLIST = mac_Info.plist
    ICON = $$PWD/icons/$${TARGET}.icns
    QMAKE_POST_LINK += $$QMAKE_COPY $$PWD/$${QMAKE_INFO_PLIST} $${TARGET}.app/Contents/Info.plist $$escape_expand(\n\t)
    QMAKE_POST_LINK += $$QMAKE_COPY $$ICON $${TARGET}.app/Contents/Resources/machinekit.icns
}

# Default rules for deployment.
include(deployment.pri)

PREFIX = /usr

target.path = $$PREFIX/bin

desktop.path = $$PREFIX/share/applications
desktop.files = $$PWD/misc/$${TARGET}.desktop

icon.path = $$PREFIX/share/pixmaps
icon.files = $$PWD/icons/$${TARGET}.png

INSTALLS += target desktop icon
