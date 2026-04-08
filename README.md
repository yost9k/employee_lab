Лабораторная работа №1
Система учета сотрудников компании

Проект представляет собой консольное приложение на Python для работы с базой данных PostgreSQL.

Реализовано:
- 5 связанных таблиц
- поиск, добавление, обновление и удаление через функции и хранимые процедуры
- 3 роли пользователей с разными правами доступа
- лог-таблицы и триггеры для аудита действий
- консольное приложение 

Команды для запуска 
init.sql монтируется в docker-entrypoint-initdb.d, может понадобиться команда docker compose down -v (нужен пустой volume)

git clone https://github.com/yost9k/employee_lab.git

cd employee_lab

pip3 install -r requirements.txt

sudo docker compose up -d

python3 app.py

Администратор: db_admin / admin123
Сервисная учетная запись: db_service / service123
Пользователь: db_user / user123
