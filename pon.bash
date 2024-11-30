#!/bin/bash

# Проверяем версию ОС
OS=$(lsb_release -is)
VERSION=$(lsb_release -rs)

if [[ "$OS" == "Ubuntu" && ( "$VERSION" == "22.04" || "$VERSION" == "24.04" ) ]] || \
   [[ "$OS" == "Debian" && ( "$VERSION" == "11" || "$VERSION" == "12" ) ]]; then
    echo "Поддерживаемая ОС: $OS $VERSION"
else
    echo "Неподдерживаемая ОС: $OS $VERSION"
    exit 1
fi

# Обновляем пакеты
sudo apt update

# Устанавливаем xfce4 и xrdp
sudo apt install -y xfce4 xfce4-goodies
sudo apt install -y xrdp

# Редактируем файл startwm.sh
STARTWM_FILE="/etc/xrdp/startwm.sh"
if [ -f "$STARTWM_FILE" ]; then
    sudo bash -c "echo 'startxfce4' | cat - $STARTWM_FILE > /tmp/startwm.sh && mv /tmp/startwm.sh $STARTWM_FILE"
    echo "Файл $STARTWM_FILE успешно обновлён."
else
    echo "Файл $STARTWM_FILE не найден."
    exit 1
fi

# Настраиваем и запускаем xrdp
sudo systemctl enable xrdp
sudo systemctl start xrdp
sudo systemctl status xrdp --no-pager

# Проверка статуса xrdp
if systemctl is-active --quiet xrdp; then
    echo "xrdp успешно запущен."
else
    echo "Ошибка запуска xrdp."
    exit 1
fi

# Добавляем "startxfce4" в ~/.xsession
echo "startxfce4" > ~/.xsession
echo "Файл .xsession успешно создан."

# Добавляем архитектуру i386
sudo dpkg --add-architecture i386

# Обновляем пакеты и устанавливаем Wine
sudo apt update
sudo apt install -y wine64 wine32
echo "Wine успешно установлен."

echo "Все шаги завершены."
