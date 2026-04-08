import psycopg2


def connect_db():
    print("Вход в систему учета сотрудников")
    username = input("Логин БД: ").strip()
    password = input("Пароль БД: ").strip()

    conn = psycopg2.connect(
        host="localhost",
        port=5432,
        dbname="employee_system",
        user=username,
        password=password
    )
    conn.autocommit = True
    return conn, username


def print_rows(rows):
    if not rows:
        print("Нет данных.")
        return
    for row in rows:
        print(row)


def search_departments(cur):
    name = input("Название отдела (Enter = все): ").strip() or None
    cur.execute("SELECT * FROM search_departments(%s);", (name,))
    print_rows(cur.fetchall())


def add_department(cur):
    name = input("Название отдела: ").strip()
    location = input("Локация офиса: ").strip()
    cur.execute("CALL add_department(%s, %s);", (name, location))
    print("Отдел добавлен.")


def update_department(cur):
    department_id = int(input("ID отдела: "))
    name = input("Новое название: ").strip()
    location = input("Новая локация: ").strip()
    cur.execute("CALL update_department(%s, %s, %s);", (department_id, name, location))
    print("Отдел обновлен.")


def delete_department(cur):
    department_id = int(input("ID отдела: "))
    cur.execute("CALL delete_department(%s);", (department_id,))
    print("Отдел удален.")


def search_positions(cur):
    name = input("Название должности (Enter = все): ").strip() or None
    cur.execute("SELECT * FROM search_positions(%s);", (name,))
    print_rows(cur.fetchall())


def add_position(cur):
    name = input("Название должности: ").strip()
    salary = float(input("Базовая зарплата: "))
    cur.execute("CALL add_position(%s, %s);", (name, salary))
    print("Должность добавлена.")


def update_position(cur):
    position_id = int(input("ID должности: "))
    name = input("Новое название: ").strip()
    salary = float(input("Новая базовая зарплата: "))
    cur.execute("CALL update_position(%s, %s, %s);", (position_id, name, salary))
    print("Должность обновлена.")


def delete_position(cur):
    position_id = int(input("ID должности: "))
    cur.execute("CALL delete_position(%s);", (position_id,))
    print("Должность удалена.")


def search_employees(cur):
    last_name = input("Фамилия сотрудника (Enter = все): ").strip() or None
    cur.execute("SELECT * FROM search_employees(%s);", (last_name,))
    print_rows(cur.fetchall())


def add_employee(cur):
    last_name = input("Фамилия: ").strip()
    first_name = input("Имя: ").strip()
    middle_name = input("Отчество (Enter = пусто): ").strip() or None
    hire_date = input("Дата приема (YYYY-MM-DD): ").strip()
    email = input("Email: ").strip()
    phone = input("Телефон: ").strip()
    department_id = int(input("ID отдела: "))
    position_id = int(input("ID должности: "))

    cur.execute(
        "CALL add_employee(%s, %s, %s, %s, %s, %s, %s, %s);",
        (last_name, first_name, middle_name, hire_date, email, phone, department_id, position_id)
    )
    print("Сотрудник добавлен.")


def update_employee(cur):
    employee_id = int(input("ID сотрудника: "))
    last_name = input("Фамилия: ").strip()
    first_name = input("Имя: ").strip()
    middle_name = input("Отчество (Enter = пусто): ").strip() or None
    hire_date = input("Дата приема (YYYY-MM-DD): ").strip()
    email = input("Email: ").strip()
    phone = input("Телефон: ").strip()
    department_id = int(input("ID отдела: "))
    position_id = int(input("ID должности: "))

    cur.execute(
        "CALL update_employee(%s, %s, %s, %s, %s, %s, %s, %s, %s);",
        (employee_id, last_name, first_name, middle_name, hire_date, email, phone, department_id, position_id)
    )
    print("Сотрудник обновлен.")


def delete_employee(cur):
    employee_id = int(input("ID сотрудника: "))
    cur.execute("CALL delete_employee(%s);", (employee_id,))
    print("Сотрудник удален.")


def search_projects(cur):
    name = input("Название проекта (Enter = все): ").strip() or None
    cur.execute("SELECT * FROM search_projects(%s);", (name,))
    print_rows(cur.fetchall())


def add_project(cur):
    name = input("Название проекта: ").strip()
    start_date = input("Дата начала (YYYY-MM-DD): ").strip()
    end_date = input("Дата окончания (YYYY-MM-DD, Enter = пусто): ").strip() or None
    budget = float(input("Бюджет: "))
    cur.execute("CALL add_project(%s, %s, %s, %s);", (name, start_date, end_date, budget))
    print("Проект добавлен.")


def update_project(cur):
    project_id = int(input("ID проекта: "))
    name = input("Название проекта: ").strip()
    start_date = input("Дата начала (YYYY-MM-DD): ").strip()
    end_date = input("Дата окончания (YYYY-MM-DD, Enter = пусто): ").strip() or None
    budget = float(input("Бюджет: "))
    cur.execute("CALL update_project(%s, %s, %s, %s, %s);", (project_id, name, start_date, end_date, budget))
    print("Проект обновлен.")


def delete_project(cur):
    project_id = int(input("ID проекта: "))
    cur.execute("CALL delete_project(%s);", (project_id,))
    print("Проект удален.")


def search_employee_projects(cur):
    employee_id_raw = input("ID сотрудника (Enter = все): ").strip()
    employee_id = int(employee_id_raw) if employee_id_raw else None
    cur.execute("SELECT * FROM search_employee_projects(%s);", (employee_id,))
    print_rows(cur.fetchall())


def add_employee_project(cur):
    employee_id = int(input("ID сотрудника: "))
    project_id = int(input("ID проекта: "))
    role = input("Роль в проекте: ").strip()
    assigned_date = input("Дата назначения (YYYY-MM-DD): ").strip()
    cur.execute(
        "CALL add_employee_project(%s, %s, %s, %s);",
        (employee_id, project_id, role, assigned_date)
    )
    print("Связь сотрудник-проект добавлена.")


def update_employee_project(cur):
    employee_project_id = int(input("ID записи: "))
    employee_id = int(input("ID сотрудника: "))
    project_id = int(input("ID проекта: "))
    role = input("Роль в проекте: ").strip()
    assigned_date = input("Дата назначения (YYYY-MM-DD): ").strip()
    cur.execute(
        "CALL update_employee_project(%s, %s, %s, %s, %s);",
        (employee_project_id, employee_id, project_id, role, assigned_date)
    )
    print("Запись обновлена.")


def delete_employee_project(cur):
    employee_project_id = int(input("ID записи: "))
    cur.execute("CALL delete_employee_project(%s);", (employee_project_id,))
    print("Запись удалена.")


def show_logs(cur):
    print("\nЛОГИ")
    print("1. Departments log")
    print("2. Positions log")
    print("3. Employees log")
    print("4. Projects log")
    print("5. Employee projects log")

    choice = input("Выберите лог: ").strip()

    if choice == "1":
        cur.execute("SELECT * FROM search_departments_log();")
    elif choice == "2":
        cur.execute("SELECT * FROM search_positions_log();")
    elif choice == "3":
        cur.execute("SELECT * FROM search_employees_log();")
    elif choice == "4":
        cur.execute("SELECT * FROM search_projects_log();")
    elif choice == "5":
        cur.execute("SELECT * FROM search_employee_projects_log();")
    else:
        print("Неверный выбор.")
        return

    print_rows(cur.fetchall())


def entity_menu(cur, title, search_fn, add_fn, update_fn, delete_fn):
    while True:
        print(f"\n[{title}]")
        print("1. Поиск")
        print("2. Добавить")
        print("3. Обновить")
        print("4. Удалить")
        print("0. Назад")

        choice = input("Выберите действие: ").strip()

        try:
            if choice == "1":
                search_fn(cur)
            elif choice == "2":
                add_fn(cur)
            elif choice == "3":
                update_fn(cur)
            elif choice == "4":
                delete_fn(cur)
            elif choice == "0":
                break
            else:
                print("Неверный выбор.")
        except Exception as e:
            print(f"Ошибка: {e}")


def main():
    try:
        conn, username = connect_db()
        cur = conn.cursor()

        print(f"\nУспешный вход: {username}")

        while True:
            print("\nГЛАВНОЕ МЕНЮ")
            print("1. Отделы")
            print("2. Должности")
            print("3. Сотрудники")
            print("4. Проекты")
            print("5. Назначения сотрудников на проекты")
            print("6. Логи")
            print("0. Выход")

            choice = input("Выберите раздел: ").strip()

            if choice == "1":
                entity_menu(cur, "ОТДЕЛЫ", search_departments, add_department, update_department, delete_department)
            elif choice == "2":
                entity_menu(cur, "ДОЛЖНОСТИ", search_positions, add_position, update_position, delete_position)
            elif choice == "3":
                entity_menu(cur, "СОТРУДНИКИ", search_employees, add_employee, update_employee, delete_employee)
            elif choice == "4":
                entity_menu(cur, "ПРОЕКТЫ", search_projects, add_project, update_project, delete_project)
            elif choice == "5":
                entity_menu(
                    cur,
                    "НАЗНАЧЕНИЯ СОТРУДНИКОВ",
                    search_employee_projects,
                    add_employee_project,
                    update_employee_project,
                    delete_employee_project
                )
            elif choice == "6":
                try:
                    show_logs(cur)
                except Exception as e:
                    print(f"Ошибка: {e}")
            elif choice == "0":
                break
            else:
                print("Неверный выбор.")

        cur.close()
        conn.close()

    except Exception as e:
        print(f"Ошибка подключения или выполнения: {e}")


if __name__ == "__main__":
    main()
