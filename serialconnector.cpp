#include "serialconnector.h"
#include <QDebug>

SerialConnector::SerialConnector(QObject *parent) : QObject(parent)
{
    m_settings = new QSettings("config.ini", QSettings::IniFormat);
    qDebug() << "Loading ini file" << m_settings->fileName();

    QObject::connect(&m_checkTimer, &QTimer::timeout, this, &SerialConnector::checkPorts);
    m_checkTimer.setInterval(m_settings->value(QStringLiteral("portCheckIntervalMs"), 2000).toInt());
    m_checkTimer.start();

    QObject::connect(&m_port1, &QSerialPort::readyRead, this, &SerialConnector::handleReadyRead);
    QObject::connect(&m_port1, &QSerialPort::errorOccurred, this, &SerialConnector::handleError);

    QObject::connect(&m_port2, &QSerialPort::readyRead, this, &SerialConnector::handleReadyRead);
    QObject::connect(&m_port2, &QSerialPort::errorOccurred, this, &SerialConnector::handleError);

    m_excludePing = m_settings->value(QStringLiteral("excludePing"), false).toBool();
}

QStringList SerialConnector::availablePorts() {
    return m_availablePorts;
}

bool SerialConnector::isConnected() {
    return m_isConnected;
}

bool SerialConnector::excludePing() {
    return m_excludePing;
}

void SerialConnector::setExcludePing(bool excludePing) {
    m_excludePing = excludePing;
    m_settings->setValue(QStringLiteral("excludePing"), m_excludePing);
    Q_EMIT(excludePingChanged());
}

int SerialConnector::cmdLength() {
    return DATA_PACKAGE_SIZE-1;
}

QVariant SerialConnector::getSetting(QString key, QVariant defaultValue) {
    return m_settings->value(key, defaultValue);
}

bool SerialConnector::connect(QString port1, QString port2) {
    qDebug() << Q_FUNC_INFO << port1 << port2;

    m_settings->setValue(QStringLiteral("port1"), port1);
    m_settings->setValue(QStringLiteral("port2"), port2);

    m_port1.setPort(QSerialPortInfo(port1));
    m_port1.setBaudRate(SERIAL_SPEED);

    m_port2.setPort(QSerialPortInfo(port2));
    m_port2.setBaudRate(SERIAL_SPEED);

    if (m_port1.open(QIODevice::ReadWrite)) {
        if (m_port2.open(QIODevice::ReadWrite)) {

            if (m_port1.isOpen() && m_port1.isReadable() && m_port1.isWritable() && m_port2.isOpen() && m_port2.isReadable() && m_port2.isWritable()) {
                m_isConnected = true;
                Q_EMIT isConnectedChanged();
                m_checkTimer.stop();
                return true;
            } else {
                qWarning() << "Ports are not accessible";
            }
        } else {
            qWarning() << "Failed to connect to port 2" << m_port2.errorString();
        }
    } else {
        qWarning() << "Failed to connect to port 1" << m_port1.errorString();
    }

    m_port1.close();
    m_port2.close();

    return false;
}

void SerialConnector::disconnect() {
    qDebug() << Q_FUNC_INFO;

    m_isConnected = false;
    Q_EMIT isConnectedChanged();
    m_checkTimer.start();

    m_port1.close();
    m_port2.close();
}

void SerialConnector::checkPorts() {
    //qDebug() << Q_FUNC_INFO;

    QStringList newList;

    QList<QSerialPortInfo> ports = QSerialPortInfo::availablePorts();
    QListIterator<QSerialPortInfo> it(ports);
    while(it.hasNext()) {
        newList << it.next().portName();
    }

    if (m_availablePorts!=newList) {
        m_availablePorts = newList;
        Q_EMIT availablePortsChanged();
    }
}

void SerialConnector::handleReadyRead() {
    QSerialPort* port = static_cast<QSerialPort*>(sender());

    if (port->bytesAvailable()<DATA_PACKAGE_SIZE+2) {
        qDebug() << "Waiting for more data" << port->bytesAvailable();
        return;
    } else {
        qDebug() << "Available bytes" << port->bytesAvailable();
    }

    while (port->canReadLine()) {
        QByteArray msg = port->readLine();

        qDebug() << Q_FUNC_INFO << port->portName() << msg;

        if (msg.at(msg.length()-2)=='\r' && msg.at(msg.length()-1)=='\n') {
            msg.chop(2);
        } else if (msg.endsWith('\n') || msg.endsWith('\r')) {
            msg.chop(1);
        }

        if (msg.startsWith(CMD_IDENTIFIER)) {
            QSerialPort* targetPort;

            if (msg.length()==4) {
                targetPort = resolvePort(port->portName(), true);

                qDebug() << "Redirecting" << msg;
                targetPort->write(msg);
                targetPort->write("\r\n");

                if (m_excludePing && (msg.at(1)==CMD_PING ||msg.at(1)==CMD_PING_FB)) {
                    qDebug() << "Ignoring ping";
                } else {
                    Q_EMIT(commMessage(port->portName(), targetPort->portName(), msg));
                }
            } else {
                qWarning() << "Invalid message length:" << msg.length();
                }
        } else {
            Q_EMIT logMessage(port->portName(), msg);
        }
    }
}

void SerialConnector::handleError() {
    QSerialPort* port = static_cast<QSerialPort*>(sender());
    if (port->error()!=QSerialPort::NoError) {
        qWarning() << Q_FUNC_INFO << port->errorString();
        //disconnect();
    }
}

QSerialPort* SerialConnector::resolvePort(QString portName, bool reverse) {
    if (portName==m_port1.portName()) {
        return reverse ? &m_port2 : &m_port1;
    } else {
        return reverse ? &m_port1 : &m_port2;
    }
}

void SerialConnector::sendCmd(QString port, QString cmd) {
    qDebug() << Q_FUNC_INFO << port << cmd;

    QSerialPort *sendPort = resolvePort(port);
    QByteArray data = cmd.prepend(CMD_IDENTIFIER).append("\r\n").toLatin1();
    qDebug() << "Sending" << data;
    sendPort->write(data);
}

QString SerialConnector::generateTooltip(QString cmd) {
    if (cmd.isEmpty()) return "";

    QString returnStr = resolveCmd(cmd.at(0));
    if (cmd.length()>1) returnStr.append("|").append(resolveMod(cmd.at(0), cmd.at(1)));
    if (cmd.length()>2) returnStr.append("|").append(cmd.at(2));

    return returnStr;
}

QString SerialConnector::resolveCmd(QChar cmd) {
    switch(cmd.toLatin1()) {
    case CMD_PING: return "Ping";
    case CMD_PING_FB: return "Ping FB";
    case CMD_VAPO: return "Vapo";
    case CMD_VAPO_FB: return "Vapo FB";
    case CMD_MM_FB: return "MM FB";
    case CMD_FAN: return "Fan";
    case CMD_FAN_FB: return "Fan FB";
    case CMD_SEAT: return "Seat";
    case CMD_SEAT_POS_FB: return "Seat Pos FB";
    case CMD_SEAT_SWITCH_FB: return "Seat Switch FB";
    case CMD_SEAT_MOVE_FB: return "Seat Move FB";
    case CMD_LEVEL_FB: return "Level FB";
    case CMD_LED_COLOR: return "LED Color";
    case CMD_LED_COLOR_FB: return "LED Color FB";
    case CMD_LED_BRIGHTNESS: return "LED Brightness";
    case CMD_LED_BRIGHTNESS_FB: return "LED Brightness FB";
    case CMD_RESTART: return "Restart";
    default:
       return QStringLiteral("Unknown: ").append(cmd);
    }
}

QString SerialConnector::resolveMod(QChar cmd, QChar mod) {
    switch(mod.toLatin1()) {
    case MOD_NONE: return "None";
    case MOD_ERROR: return "Error";
    case MOD_LEFT: return "Left";
    case MOD_MIDDLE:        // MOD_LED_MIDDLE_STRIP
        switch(cmd.toLatin1()) {
        case CMD_VAPO:
        case CMD_VAPO_FB:
        case CMD_MM_FB:
        case CMD_LEVEL_FB:
            return "Middle";
        case CMD_LED_COLOR:
        case CMD_LED_COLOR_FB:
        case CMD_LED_BRIGHTNESS:
        case CMD_LED_BRIGHTNESS_FB:
            return "LED MS";
        default:
            return QStringLiteral("Unknown: ").append(mod);
        }
    case MOD_RIGHT: return "Right";
    case MOD_LED_DASHBOARD: return "LED DB";
    case MOD_LED_FINS: return "LED Fins";
    case MOD_LED_CABLE_HOLDER: return "LED CH";
    case MOD_LED_HEADLIGHTS: return "LED HL";
    case MOD_LED_HEADLIGHTS_AMB: return "LED LHA";
    default:
        return QStringLiteral("Unknown: ").append(mod);
    }
}

