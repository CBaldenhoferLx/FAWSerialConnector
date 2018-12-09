#include "serialconnector.h"
#include <QDebug>

SerialConnector::SerialConnector(QObject *parent) : QObject(parent)
{
    m_isConnected = false;

    QObject::connect(&m_checkTimer, &QTimer::timeout, this, &SerialConnector::checkPorts);
    m_checkTimer.setInterval(2000);
    m_checkTimer.start();

    QObject::connect(&m_port1, &QSerialPort::readyRead, this, &SerialConnector::handleReadyRead);
    QObject::connect(&m_port1, &QSerialPort::errorOccurred, this, &SerialConnector::handleError);

    QObject::connect(&m_port2, &QSerialPort::readyRead, this, &SerialConnector::handleReadyRead);
    QObject::connect(&m_port2, &QSerialPort::errorOccurred, this, &SerialConnector::handleError);
}

QStringList SerialConnector::availablePorts() {
    return m_availablePorts;
}

bool SerialConnector::isConnected() {
    return m_isConnected;
}

int SerialConnector::cmdLength() {
    return DATA_PACKAGE_SIZE-1;
}

bool SerialConnector::connect(QString port1, QString port2) {
    qDebug() << Q_FUNC_INFO << port1 << port2;

    m_port1.setPort(QSerialPortInfo(port1));
    m_port1.setBaudRate(SERIAL_SPEED);

    m_port2.setPort(QSerialPortInfo(port2));
    m_port2.setBaudRate(SERIAL_SPEED);

    if (m_port1.open(QIODevice::ReadWrite)) {
        if (m_port2.open(QIODevice::ReadWrite)) {
            m_isConnected = true;
            Q_EMIT isConnectedChanged();
            m_checkTimer.stop();
            return true;
        } else {
            qWarning() << "Failed to connect to port 2" << m_port2.errorString();
        }
    } else {
        qWarning() << "Failed to connect to port 1" << m_port1.errorString();
    }

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

    QByteArray msg = port->readLine();

    qDebug() << Q_FUNC_INFO << port->portName() << msg;

    if (msg.startsWith(CMD_IDENTIFIER)) {
        QSerialPort* targetPort;

        if (msg.at(msg.length()-2)=='\r' && msg.at(msg.length()-1)=='\n') {
            msg.chop(2);
        } else if (msg.endsWith('\n') || msg.endsWith('\r')) {
            msg.chop(1);
        }

        if (msg.length()==4) {
            targetPort = resolvePort(port->portName(), true);

            targetPort->write(msg);

            Q_EMIT(commMessage(port->portName(), targetPort->portName(), msg));
        } else {
            qWarning() << "Invalid messag length:" << msg.length();
        }
    } else {
        Q_EMIT logMessage(port->portName(), msg);
    }
}

void SerialConnector::handleError() {

}

QSerialPort* SerialConnector::resolvePort(QString portName, bool reverse) {
    if (portName==m_port1.portName()) {
        return reverse ? &m_port2 : &m_port1;
    } else {
        return reverse ? &m_port1 : &m_port2;
    }
}

void SerialConnector::sendCmd(QString port, QString cmd) {
    QSerialPort *sendPort = resolvePort(port);
    sendPort->write(cmd.prepend(CMD_IDENTIFIER).append("\r\n").toLatin1());
}

QString SerialConnector::generateTooltip(QString cmd) {
    if (cmd.isEmpty()) return "";

    if (cmd.startsWith(CMD_VAPO)) {
        return "Vapo";
    } else {
        return "Unknown command";
    }
}

