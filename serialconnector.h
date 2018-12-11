#ifndef SERIALCONNECTOR_H
#define SERIALCONNECTOR_H

#include <QObject>
#include <QSerialPort>
#include <QSerialPortInfo>
#include <QTimer>
#include <QSettings>

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
    Q_PROPERTY(bool excludePing READ excludePing WRITE setExcludePing NOTIFY excludePingChanged)

    QStringList availablePorts();
    bool isConnected();
    int cmdLength();
    bool excludePing();
    void setExcludePing(bool excludePing);

    Q_INVOKABLE bool connect(QString port1, QString port2);
    Q_INVOKABLE void disconnect();

    Q_INVOKABLE void sendCmd(QString port, QString cmd);
    Q_INVOKABLE QString generateTooltip(QString cmd);

    Q_INVOKABLE QVariant getSetting(QString key, QVariant defaultValue);

signals:
    void availablePortsChanged();
    void isConnectedChanged();
    void cmdLengthChanged();
    void excludePingChanged();

    void logMessage(QString port, QString message);
    void commMessage(QString source, QString target, QString msg);

private:
    QSettings* m_settings;

    QStringList m_availablePorts;
    bool m_isConnected = false;
    bool m_excludePing = false;

    QTimer m_checkTimer;

    QSerialPort m_port1;
    QSerialPort m_port2;

    QSerialPort* resolvePort(QString portName, bool reverse = false);

    QString resolveCmd(QChar cmd);
    QString resolveMod(QChar cmd, QChar mod);

private slots:
    void checkPorts();

    void handleReadyRead();
    void handleError();

public slots:
};

#endif // SERIALCONNECTOR_H
