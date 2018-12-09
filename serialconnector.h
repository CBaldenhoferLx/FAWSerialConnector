#ifndef SERIALCONNECTOR_H
#define SERIALCONNECTOR_H

#include <QObject>
#include <QSerialPort>
#include <QSerialPortInfo>
#include <QTimer>
#include "Protocol.h"
#include "GlobalConstants.h"

class SerialConnector : public QObject
{
    Q_OBJECT
public:
    explicit SerialConnector(QObject *parent = nullptr);

    Q_PROPERTY(QStringList availablePorts READ availablePorts NOTIFY availablePortsChanged)
    Q_PROPERTY(bool isConnected READ isConnected NOTIFY isConnectedChanged)
    Q_PROPERTY(int cmdLength READ cmdLength NOTIFY cmdLengthChanged)

    QStringList availablePorts();
    bool isConnected();
    int cmdLength();

    Q_INVOKABLE bool connect(QString port1, QString port2);
    Q_INVOKABLE void disconnect();

    Q_INVOKABLE void sendCmd(QString port, QString cmd);
    Q_INVOKABLE QString generateTooltip(QString cmd);

signals:
    void availablePortsChanged();
    void isConnectedChanged();
    void cmdLengthChanged();

    void logMessage(QString port, QString message);
    void commMessage(QString source, QString target, QString msg);

private:
    QStringList m_availablePorts;
    bool m_isConnected;

    QTimer m_checkTimer;

    QSerialPort m_port1;
    QSerialPort m_port2;

    QSerialPort* resolvePort(QString portName, bool reverse = false);

private slots:
    void checkPorts();

    void handleReadyRead();
    void handleError();

public slots:
};

#endif // SERIALCONNECTOR_H
