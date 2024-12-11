#!/bin/bash

function banner() {
    echo -e "\e[38;5;196m▄▄▄       ██▀███   ▄████▄   ██░ ██  ▄▄▄       ███▄    █   ▄████ ▓█████  ██▓     ▒█████   ██▒   █▓"
    echo -e "\e[38;5;202m▒████▄    ▓██ ▒ ██▒▒██▀ ▀█  ▓██░ ██▒▒████▄     ██ ▀█   █  ██▒ ▀█▒▓█   ▀ ▓██▒    ▒██▒  ██▒▓██░   █▒"
    echo -e "\e[38;5;208m▒██  ▀█▄  ▓██ ░▄█ ▒▒▓█    ▄ ▒██▀▀██░▒██  ▀█▄  ▓██  ▀█ ██▒▒██░▄▄▄░▒███   ▒██░    ▒██░  ██▒ ▓██  █▒░"
    echo -e "\e[38;5;214m░██▄▄▄▄██ ▒██▀▀█▄  ▒▓▓▄ ▄██▒░▓█ ░██ ░██▄▄▄▄██ ▓██▒  ▐▌██▒░▓█  ██▓▒▓█  ▄ ▒██░    ▒██   ██░  ▒██ █░░"
    echo -e "\e[38;5;220m ▓█   ▓██▒░██▓ ▒██▒▒ ▓███▀ ░░▓█▒░██▓ ▓█   ▓██▒▒██░   ▓██░░▒▓███▀▒░▒████▒░██████▒░ ████▓▒░   ▒▀█░  "
    echo -e "\e[38;5;226m ▒▒   ▓▒█░░ ▒▓ ░▒▓░░ ░▒ ▒  ░ ▒ ░░▒░▒ ▒▒   ▓▒█░░ ▒░   ▒ ▒  ░▒   ▒ ░░ ▒░ ░░ ▒░▓  ░░ ▒░▒░▒░    ░ ▐░  "
    echo -e "\e[38;5;226m  ▒   ▒▒ ░  ░▒ ░ ▒░  ░  ▒    ▒ ░▒░ ░  ▒   ▒▒ ░░ ░░   ░ ▒░  ░   ░  ░ ░  ░░ ░ ▒  ░  ░ ▒ ▒░    ░ ░░  "
    echo -e "\e[38;5;226m  ░   ▒     ░░   ░ ░         ░  ░░ ░  ░   ▒      ░   ░ ░ ░ ░   ░    ░     ░ ░   ░ ░ ░ ▒       ░░  "
    echo -e "\e[38;5;226m      ░  ░   ░     ░ ░       ░  ░  ░      ░  ░         ░       ░    ░  ░    ░  ░    ░ ░        ░  "
    echo -e "\e[0m"  
}

function search_in_file() {
    file_path=$1
    keyword=$2

    # Проверка типа файла
    if [[ $file_path == *.csv || $file_path == *.txt || $file_path == *.sql ]]; then
        # Скачиваем файл на локальную машину
        lftp -e "get $file_path -o /tmp/temp_file; bye" -u $FTP_USER,$FTP_PASS $FTP_SERVER
        # Выполняем поиск с помощью awk
        awk -v keyword="$keyword" 'BEGIN {IGNORECASE=1} {if ($0 ~ keyword) print NR ": " $0}' /tmp/temp_file
        # Удаляем временный файл
        rm /tmp/temp_file
    elif [[ $file_path == *.xlsx || $file_path == *.xls ]]; then
        # Скачиваем файл на локальную машину
        lftp -e "get $file_path -o /tmp/temp_file; bye" -u $FTP_USER,$FTP_PASS $FTP_SERVER
        # Конвертируем xlsx в csv и выполняем поиск с помощью awk
        xls2csv /tmp/temp_file | awk -v keyword="$keyword" 'BEGIN {IGNORECASE=1} {if ($0 ~ keyword) print NR ": " $0}'
        # Удаляем временный файл
        rm /tmp/temp_file
    fi
}

function search_keyword_in_ftp() {
    ftp_directory=$1
    keyword=$2

    # Получение списка файлов в FTP директории
    lftp -e "cls $ftp_directory; bye" -u $FTP_USER,$FTP_PASS $FTP_SERVER | while read file_path; do
        if [[ $file_path == *.csv || $file_path == *.txt || $file_path == *.sql || $file_path == *.xlsx || $file_path == *.xls ]]; then
            search_in_file "$file_path" "$keyword"
        fi
    done
}

function main() {
    clear
    banner  

    # Параметры FTP (указаны вами)
    FTP_SERVER="storage.bunnycdn.com"
    FTP_USER="lunardatabase"  # Укажите ваш FTP-логин
    FTP_PASS="6507f915-cdbf-4332-8a9f700b81d4-7bca-461f"  # Пароль
    FTP_DIR="/lunardatabase/database"  # Директория на FTP-сервере

    while true; do
        echo "Меню:"
        echo "1. Поиск по запросу"
        echo "2. Выход"
        read -p "Выберите пункт меню (1-2): " choice

        if [ "$choice" == "1" ]; then
            read -p "Введите запрос для поиска: " keyword
            echo "Поиск по запросу: '$keyword'..."
            search_keyword_in_ftp "$FTP_DIR" "$keyword"
            read -p "Нажмите Enter, чтобы продолжить..."
        elif [ "$choice" == "2" ]; then
            echo "Выход из программы."
            break
        else
            echo "Неверный выбор. Пожалуйста, выберите 1 или 2."
            read -p "Нажмите Enter, чтобы продолжить..."
        fi
    done
}

main
