#!/bin/sh

# Скрипт для резервного копирования файлов на FTP
# Автозапуск в сrontab: 0 4 * * * sh /opt/backup.sh >> /opt/cron.log 2>&1
# by Sergio Leone
# rev.2020.10.29

echo "\n >> ПОЕХАЛИ! $(date +%c)"

NAME="MWTV"				# Название папки и файлов бэкапа
USER="backup"			# Логин
PASS="backup"			# Пароль
URL="10.10.0.84"		# IP адрес FTP сервера
PORT="22"				# Порт FTP сервера
NOW=$(date +%Y-%m-%d)												# Текущая дата
ARCHIVE=$NAME-$NOW.tar.gz											# Формат названия нового архива
OLD_ARCHIVE=$NAME-$(date -d 'now -180 days' +"%Y-%m-%d").tar.gz		# Формируем название старого архива для удаления
echo "$NAME $URL:$PORT"

echo " >> СОЗДАНИЕ ВРЕМЕННЫХ ПАПОК..."

mkdir -v /tmp/$NAME
mkdir -v /tmp/$NAME/$NOW
cd /tmp/$NAME/$NOW

echo " >> УПАКОВКА КАТАЛОГОВ В АРХИВ..."

tar -cf opt.tar /opt
tar -cf var_spool_cron_crontabs.tar /var/spool/cron/crontabs
tar -cf etc_monit.tar /etc/monit
tar -cf etc_network_interfaces.tar /etc/network/interfaces
tar -cf var_www_stalker_portal_server_config.tar /var/www/stalker_portal/server/config.ini

TARS="opt.tar"
TARS="$TARS var_spool_cron_crontabs.tar"
TARS="$TARS etc_monit.tar"
TARS="$TARS etc_network_interfaces.tar"
TARS="$TARS var_www_stalker_portal_server_config.tar"

tar -jcvf $ARCHIVE $TARS

echo " >> ОТПРАВКА АРХИВА..."

ftp -n -v $URL $PORT <<END_SCRIPT
user $USER $PASS
cd $NAME
put $ARCHIVE
delete $OLD_ARCHIVE
quit
END_SCRIPT

echo " >> УДАЛЕНИЕ ВРЕМЕННЫХ ПАПОК И ФАЙЛОВ..."

rm -rf -v /tmp/$NAME/

echo " >> ОТПРАВКА ЗАВЕРШЕНА\n"
