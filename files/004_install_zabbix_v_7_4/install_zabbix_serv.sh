#!/bin/bash
# Дата создания 16.01.2026

REMOTE_USER="osho"
REMOTE_SERVER="62.84.125.126"

echo "[-->] Start"

# Запускаем всё содержимое через sudo bash, чтобы не писать sudo перед каждой командой
    # -q (quiet): "Тихий" режим. Подавляет большинство предупреждений и диагностических сообщений
    # -t (tty): Принудительное выделение псевдо-терминала (TTY). Это необходимо для запуска интерактивных программ на удаленном сервере (например, top, vim или sudo, требующее ввода пароля)
ssh -q -t -o StrictHostKeyChecking=no $REMOTE_USER@$REMOTE_SERVER << 'EOF' > /dev/null
    
    # Опция 'set -e' остановит скрипт при любой ошибке (как в Ansible)
    set -e
    
    # Добавляем переменную окружения и сообщения debconf исчезнут
    export DEBIAN_FRONTEND=noninteractive

    echo "[+] Обновление информации о репозитории" >&2
    sudo -E apt-get update -qq

    echo "[+] Установка PostgreSQL" >&2
    sudo -E apt-get install -y -qq postgresql

    echo "[+] Установка Zabbix репозитория" >&2
    cd /tmp
    if [[ ! -f zabbix-release_latest_7.4+ubuntu22.04_all.deb ]]; then
        wget -q https://repo.zabbix.com/zabbix/7.4/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.4+ubuntu22.04_all.deb
        sudo -E dpkg -i zabbix-release_latest_7.4+ubuntu22.04_all.deb > /dev/null
    fi
    sudo -E apt-get update -qq

    echo "[+] Установка Zabbix компонентов" >&2

    # Убрана привязку к версии php8.1 для гибкости
    sudo -E apt-get install -y -qq zabbix-server-pgsql zabbix-frontend-php php-pgsql zabbix-apache-conf zabbix-sql-scripts zabbix-agent

    echo "[+] Настройка базы данных" >&2

    # Проверка существования пользователя/базы, чтобы скрипт был идемпотентным (не выдавал ошибок при повторе)
    sudo -E -u postgres psql -tc "SELECT 1 FROM pg_user WHERE usename = 'zabbix'" | grep -q 1 || \
    sudo -E -u postgres psql -c "CREATE USER zabbix WITH PASSWORD '123456789';"
    
    sudo -E -u postgres psql -lqt | cut -d \| -f 1 | grep -qw zabbix || \
    sudo -E -u postgres psql -c "CREATE DATABASE zabbix OWNER zabbix;"

    echo "[+] Импорт схемы данных" >&2

    # Используем одинарные кавычки в начале EOF (см. выше), тогда внутри не нужно экранировать $
    comm=$(sudo -u postgres psql zabbix -tAc "SELECT EXISTS (SELECT FROM information_schema.tables WHERE table_name = 'users');")
    if [[ "$comm" != "t" ]]; then
        zcat /usr/share/zabbix/sql-scripts/postgresql/server.sql.gz | sudo -u zabbix psql zabbix
    fi
    
    echo "[+] Конфигурация Zabbix Server" >&2
    
    # Флаг -q (quiet) означает «ничего не выводить на экран, просто вернуть код 0, если строка найдена, и 1, если нет
    if sudo -E grep -q "# DBPassword=" /etc/zabbix/zabbix_server.conf; then
        sudo -E sed -i 's/# DBPassword=/DBPassword=123456789/g' /etc/zabbix/zabbix_server.conf
    fi

    echo "[+] Запуск служб" >&2
    sudo -E systemctl restart zabbix-server apache2 zabbix-agent
    sudo -E systemctl enable --quiet zabbix-server apache2 zabbix-agent
EOF

echo "[-->] Done"