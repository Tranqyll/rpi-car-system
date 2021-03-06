/*
 * This file is part of RPI Car System.
 * Copyright (c) 2016 Fabien Caylus <tranqyll.dev@gmail.com>
 *
 * This file is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "tshandler.h"

#include <linux/types.h>
#include <linux/input.h>
#include <linux/hidraw.h>

#include <sys/ioctl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

#include <cstdio>
#include <cstring>
#include <cstdlib>

#include <QPoint>
#include <QDebug>
#include <QMouseEvent>
#include <QDir>
#include <QGuiApplication>
#include <QQuickView>
#include <QQuickItem>
#include <QThread>

TSHandler::TSHandler(QQuickView *view, QObject *parent) : QObject(parent)
{
    _view = view;
}

void TSHandler::handle()
{
    qDebug() << "Search for touchscreen ...";

    QDir devDir("/dev");
    QStringList hidrawList = devDir.entryList(QStringList({"hidraw*"}), QDir::Files | QDir::System);

    int foundFd = -1;

    for(QString hidrawPath : hidrawList)
    {
        const int fd = open(QString("/dev/" + hidrawPath).toStdString().c_str(), O_RDWR);

        if(fd < 0)
            continue;

        struct hidraw_devinfo info;
        memset(&info, 0x0, sizeof(info));

        const int ret = ioctl(fd, HIDIOCGRAWINFO, &info);
        if(ret < 0)
        {
            qWarning() << strerror(errno);
            close(fd);
            continue;
        }

        // Check product and vendor information
        // Only handle this device:
        // http://www.waveshare.com/wiki/7inch_HDMI_LCD_(B)
        if(info.vendor == QString("0x0EEF").toInt(0, 16)
           && info.product == QString("0x0005").toInt(0, 16))
        {
            foundFd = fd;
            break;
        }

        close(_fd);
        continue;
    }

    if(foundFd < 0)
    {
        qWarning() << "No touch screen found !";
        return;
    }

    // Handle the device and start the loop
    qDebug() << "Found a touchscreen";

    bool lastPressed = false;
    uint16_t lastX = 0;
    uint16_t lastY = 0;

    uint8_t buf[30];
    memset(buf, 0x0, sizeof(buf));

    struct timeval tv;
    tv.tv_sec = 0;
    tv.tv_usec = 0;

    int ret = -1;

    while(!thread()->isInterruptionRequested())
    {
        // Set up vars for select()
        fd_set fds;
        FD_ZERO(&fds);
        FD_SET(foundFd, &fds);

        ret = select(foundFd+1, &fds, NULL, NULL, &tv);

        // If data are available
        if(ret > 0 && FD_ISSET(foundFd, &fds))
        {
            ret = read(foundFd, buf, 25);

            // Messages format: [tag] [pressed] [x] [y]
            // sizes in Bytes:    1       1      2   2
            if(ret < 6)
            {
                if(ret == -1)
                    qWarning() << "TS: Error while reading:" << strerror(errno);
                else if(ret == 0)
                    qWarning() << "TS: End of file";
                else
                    qWarning() << "TS: Read only" << ret << "bytes";

                continue;
            }

            // false == 0 and true == 1
            bool pressed = buf[1] != 0;
            uint16_t x = ((uint16_t)buf[2] << 8) | buf[3];
            uint16_t y = ((uint16_t)buf[4] << 8) | buf[5];

            const int dx = std::abs(x - lastX);
            const int dy = std::abs(y - lastY);

            //qDebug() << buf[0] << pressed << x << y;

            QPoint pt = QPoint(x,y);

            if((dx > 0 || dy > 0) && x != 0 && y != 0)
            {
                if(lastX != 0 && lastY != 0)
                {
                    qDebug() << "TS moved at: " << pt;
                    QGuiApplication::postEvent(_view,
                                                new QMouseEvent(QEvent::MouseMove,
                                                                pt,
                                                                pt,
                                                                pt,
                                                                Qt::NoButton,
                                                                Qt::LeftButton,
                                                                Qt::NoModifier));
                }

                lastX = x;
                lastY = y;
            }

            if(pressed && !lastPressed)
            {
                // Ugly workaround
                // Prevent items to "grab the user input" after each clicks
                _view->rootObject()->grabMouse();
                _view->rootObject()->ungrabMouse();

                qDebug() << "TS pressed at: " << pt;
                QGuiApplication::postEvent(_view,
                                            new QMouseEvent(QEvent::MouseButtonPress,
                                                            pt,
                                                            pt,
                                                            pt,
                                                            Qt::LeftButton,
                                                            Qt::LeftButton,
                                                            Qt::NoModifier));
                lastPressed = true;
            }
            else if(lastPressed && !pressed)
            {
                QPoint lastPt = QPoint(lastX, lastY);
                qDebug() << "TS released at: " << lastPt;
                QGuiApplication::postEvent(_view,
                                            new QMouseEvent(QEvent::MouseButtonRelease,
                                                            lastPt,
                                                            lastPt,
                                                            lastPt,
                                                            Qt::LeftButton,
                                                            Qt::LeftButton,
                                                            Qt::NoModifier));
                lastPressed = false;
            }
        }

        usleep(100*1000);
    }

    qDebug() << "Exiting TS loop ...";

    close(foundFd);
}
