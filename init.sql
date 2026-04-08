CREATE TABLE IF NOT EXISTS departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    office_location VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS positions (
    position_id SERIAL PRIMARY KEY,
    position_name VARCHAR(100) NOT NULL UNIQUE,
    base_salary NUMERIC(10,2) NOT NULL CHECK (base_salary >= 0)
);

CREATE TABLE IF NOT EXISTS employees (
    employee_id SERIAL PRIMARY KEY,
    last_name VARCHAR(100) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    middle_name VARCHAR(100),
    hire_date DATE NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL UNIQUE,
    department_id INT NOT NULL REFERENCES departments(department_id) ON DELETE RESTRICT,
    position_id INT NOT NULL REFERENCES positions(position_id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(150) NOT NULL UNIQUE,
    start_date DATE NOT NULL,
    end_date DATE,
    budget NUMERIC(12,2) NOT NULL CHECK (budget >= 0)
);

CREATE TABLE IF NOT EXISTS employee_projects (
    employee_project_id SERIAL PRIMARY KEY,
    employee_id INT NOT NULL REFERENCES employees(employee_id) ON DELETE CASCADE,
    project_id INT NOT NULL REFERENCES projects(project_id) ON DELETE CASCADE,
    role_in_project VARCHAR(100) NOT NULL,
    assigned_date DATE NOT NULL,
    UNIQUE (employee_id, project_id)
);

-- FUNCTIONS FOR SEARCH (SELECT)


CREATE OR REPLACE FUNCTION search_departments(p_department_name VARCHAR DEFAULT NULL)
RETURNS TABLE (
    department_id INT,
    department_name VARCHAR,
    office_location VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT d.department_id, d.department_name, d.office_location
    FROM departments d
    WHERE p_department_name IS NULL
       OR d.department_name ILIKE '%' || p_department_name || '%'
    ORDER BY d.department_id;
END;
$$;

CREATE OR REPLACE FUNCTION search_positions(p_position_name VARCHAR DEFAULT NULL)
RETURNS TABLE (
    position_id INT,
    position_name VARCHAR,
    base_salary NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT p.position_id, p.position_name, p.base_salary
    FROM positions p
    WHERE p_position_name IS NULL
       OR p.position_name ILIKE '%' || p_position_name || '%'
    ORDER BY p.position_id;
END;
$$;

CREATE OR REPLACE FUNCTION search_employees(p_last_name VARCHAR DEFAULT NULL)
RETURNS TABLE (
    employee_id INT,
    last_name VARCHAR,
    first_name VARCHAR,
    middle_name VARCHAR,
    hire_date DATE,
    email VARCHAR,
    phone VARCHAR,
    department_name VARCHAR,
    position_name VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT e.employee_id,
           e.last_name,
           e.first_name,
           e.middle_name,
           e.hire_date,
           e.email,
           e.phone,
           d.department_name,
           p.position_name
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id
    JOIN positions p ON e.position_id = p.position_id
    WHERE p_last_name IS NULL
       OR e.last_name ILIKE '%' || p_last_name || '%'
    ORDER BY e.employee_id;
END;
$$;

CREATE OR REPLACE FUNCTION search_projects(p_project_name VARCHAR DEFAULT NULL)
RETURNS TABLE (
    project_id INT,
    project_name VARCHAR,
    start_date DATE,
    end_date DATE,
    budget NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT pr.project_id, pr.project_name, pr.start_date, pr.end_date, pr.budget
    FROM projects pr
    WHERE p_project_name IS NULL
       OR pr.project_name ILIKE '%' || p_project_name || '%'
    ORDER BY pr.project_id;
END;
$$;

CREATE OR REPLACE FUNCTION search_employee_projects(p_employee_id INT DEFAULT NULL)
RETURNS TABLE (
    employee_project_id INT,
    employee_full_name TEXT,
    project_name VARCHAR,
    role_in_project VARCHAR,
    assigned_date DATE
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT ep.employee_project_id,
           e.last_name || ' ' || e.first_name || COALESCE(' ' || e.middle_name, '') AS employee_full_name,
           pr.project_name,
           ep.role_in_project,
           ep.assigned_date
    FROM employee_projects ep
    JOIN employees e ON ep.employee_id = e.employee_id
    JOIN projects pr ON ep.project_id = pr.project_id
    WHERE p_employee_id IS NULL
       OR ep.employee_id = p_employee_id
    ORDER BY ep.employee_project_id;
END;
$$;

-- PROCEDURES FOR INSERT


CREATE OR REPLACE PROCEDURE add_department(
    p_department_name VARCHAR,
    p_office_location VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO departments (department_name, office_location)
    VALUES (p_department_name, p_office_location);
END;
$$;

CREATE OR REPLACE PROCEDURE add_position(
    p_position_name VARCHAR,
    p_base_salary NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO positions (position_name, base_salary)
    VALUES (p_position_name, p_base_salary);
END;
$$;

CREATE OR REPLACE PROCEDURE add_employee(
    p_last_name VARCHAR,
    p_first_name VARCHAR,
    p_middle_name VARCHAR,
    p_hire_date DATE,
    p_email VARCHAR,
    p_phone VARCHAR,
    p_department_id INT,
    p_position_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO employees (
        last_name, first_name, middle_name, hire_date,
        email, phone, department_id, position_id
    )
    VALUES (
        p_last_name, p_first_name, p_middle_name, p_hire_date,
        p_email, p_phone, p_department_id, p_position_id
    );
END;
$$;

CREATE OR REPLACE PROCEDURE add_project(
    p_project_name VARCHAR,
    p_start_date DATE,
    p_end_date DATE,
    p_budget NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO projects (project_name, start_date, end_date, budget)
    VALUES (p_project_name, p_start_date, p_end_date, p_budget);
END;
$$;

CREATE OR REPLACE PROCEDURE add_employee_project(
    p_employee_id INT,
    p_project_id INT,
    p_role_in_project VARCHAR,
    p_assigned_date DATE
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO employee_projects (
        employee_id, project_id, role_in_project, assigned_date
    )
    VALUES (
        p_employee_id, p_project_id, p_role_in_project, p_assigned_date
    );
END;
$$;


-- PROCEDURES FOR UPDATE


CREATE OR REPLACE PROCEDURE update_department(
    p_department_id INT,
    p_department_name VARCHAR,
    p_office_location VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE departments
    SET department_name = p_department_name,
        office_location = p_office_location
    WHERE department_id = p_department_id;
END;
$$;

CREATE OR REPLACE PROCEDURE update_position(
    p_position_id INT,
    p_position_name VARCHAR,
    p_base_salary NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE positions
    SET position_name = p_position_name,
        base_salary = p_base_salary
    WHERE position_id = p_position_id;
END;
$$;

CREATE OR REPLACE PROCEDURE update_employee(
    p_employee_id INT,
    p_last_name VARCHAR,
    p_first_name VARCHAR,
    p_middle_name VARCHAR,
    p_hire_date DATE,
    p_email VARCHAR,
    p_phone VARCHAR,
    p_department_id INT,
    p_position_id INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE employees
    SET last_name = p_last_name,
        first_name = p_first_name,
        middle_name = p_middle_name,
        hire_date = p_hire_date,
        email = p_email,
        phone = p_phone,
        department_id = p_department_id,
        position_id = p_position_id
    WHERE employee_id = p_employee_id;
END;
$$;

CREATE OR REPLACE PROCEDURE update_project(
    p_project_id INT,
    p_project_name VARCHAR,
    p_start_date DATE,
    p_end_date DATE,
    p_budget NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE projects
    SET project_name = p_project_name,
        start_date = p_start_date,
        end_date = p_end_date,
        budget = p_budget
    WHERE project_id = p_project_id;
END;
$$;

CREATE OR REPLACE PROCEDURE update_employee_project(
    p_employee_project_id INT,
    p_employee_id INT,
    p_project_id INT,
    p_role_in_project VARCHAR,
    p_assigned_date DATE
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE employee_projects
    SET employee_id = p_employee_id,
        project_id = p_project_id,
        role_in_project = p_role_in_project,
        assigned_date = p_assigned_date
    WHERE employee_project_id = p_employee_project_id;
END;
$$;

-- PROCEDURES FOR DELETE

CREATE OR REPLACE PROCEDURE delete_department(p_department_id INT)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM departments
    WHERE department_id = p_department_id;
END;
$$;

CREATE OR REPLACE PROCEDURE delete_position(p_position_id INT)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM positions
    WHERE position_id = p_position_id;
END;
$$;

CREATE OR REPLACE PROCEDURE delete_employee(p_employee_id INT)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM employees
    WHERE employee_id = p_employee_id;
END;
$$;

CREATE OR REPLACE PROCEDURE delete_project(p_project_id INT)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM projects
    WHERE project_id = p_project_id;
END;
$$;

CREATE OR REPLACE PROCEDURE delete_employee_project(p_employee_project_id INT)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM employee_projects
    WHERE employee_project_id = p_employee_project_id;
END;
$$;

-- FILLING TABLES THROUGH PROCEDURES

CALL add_department('IT', 'Building A');
CALL add_department('HR', 'Building B');
CALL add_department('Finance', 'Building C');
CALL add_department('Marketing', 'Building D');
CALL add_department('Sales', 'Building E');

CALL add_position('Junior Developer', 60000);
CALL add_position('Senior Developer', 120000);
CALL add_position('HR Manager', 70000);
CALL add_position('Accountant', 80000);
CALL add_position('Marketing Specialist', 65000);
CALL add_position('Sales Manager', 75000);
CALL add_position('Project Manager', 110000);

CALL add_employee('Иванов', 'Иван', 'Иванович', '2021-03-10', 'ivanov@company.ru', '+79000000001', 1, 1);
CALL add_employee('Петров', 'Пётр', 'Сергеевич', '2020-07-15', 'petrov@company.ru', '+79000000002', 1, 2);
CALL add_employee('Сидорова', 'Анна', 'Олеговна', '2022-01-20', 'sidorova@company.ru', '+79000000003', 2, 3);
CALL add_employee('Козлов', 'Олег', 'Андреевич', '2019-11-05', 'kozlov@company.ru', '+79000000004', 3, 4);
CALL add_employee('Смирнова', 'Елена', 'Викторовна', '2023-04-18', 'smirnova@company.ru', '+79000000005', 4, 5);
CALL add_employee('Волков', 'Дмитрий', 'Алексеевич', '2021-09-01', 'volkov@company.ru', '+79000000006', 5, 6);
CALL add_employee('Морозова', 'Мария', 'Игоревна', '2020-02-12', 'morozova@company.ru', '+79000000007', 1, 7);
CALL add_employee('Фёдоров', 'Никита', 'Павлович', '2022-08-23', 'fedorov@company.ru', '+79000000008', 1, 1);
CALL add_employee('Новикова', 'Ольга', 'Романовна', '2021-06-30', 'novikova@company.ru', '+79000000009', 2, 3);
CALL add_employee('Орлов', 'Максим', 'Евгеньевич', '2018-12-14', 'orlov@company.ru', '+79000000010', 3, 4);
CALL add_employee('Павлова', 'Ксения', 'Дмитриевна', '2023-01-09', 'pavlova@company.ru', '+79000000011', 4, 5);
CALL add_employee('Соколов', 'Артём', 'Владимирович', '2019-05-25', 'sokolov@company.ru', '+79000000012', 5, 6);
CALL add_employee('Зайцев', 'Илья', 'Олегович', '2020-10-17', 'zaytsev@company.ru', '+79000000013', 1, 2);
CALL add_employee('Егорова', 'Дарья', 'Станиславовна', '2022-03-11', 'egorova@company.ru', '+79000000014', 4, 5);
CALL add_employee('Беляев', 'Роман', 'Игоревич', '2021-07-07', 'belyaev@company.ru', '+79000000015', 5, 7);

CALL add_project('CRM Upgrade', '2026-01-10', '2026-06-30', 1500000);
CALL add_project('Corporate Portal', '2026-02-01', '2026-08-15', 2000000);
CALL add_project('HR Automation', '2026-01-20', '2026-05-30', 900000);
CALL add_project('Budget Planning 2026', '2026-01-05', '2026-04-25', 750000);
CALL add_project('Ad Campaign Spring', '2026-03-01', '2026-05-31', 650000);
CALL add_project('Sales Analytics', '2026-02-10', '2026-07-20', 1300000);
CALL add_project('Mobile App', '2026-01-15', '2026-09-30', 2500000);
CALL add_project('Employee Onboarding', '2026-02-05', '2026-04-30', 400000);
CALL add_project('Website Redesign', '2026-03-12', '2026-07-01', 850000);
CALL add_project('Data Warehouse', '2026-01-25', '2026-10-31', 3000000);

CALL add_employee_project(1, 1, 'Backend Developer', '2026-01-12');
CALL add_employee_project(2, 1, 'Lead Developer', '2026-01-12');
CALL add_employee_project(7, 1, 'Project Manager', '2026-01-12');
CALL add_employee_project(3, 3, 'HR Analyst', '2026-01-22');
CALL add_employee_project(9, 3, 'HR Coordinator', '2026-01-22');
CALL add_employee_project(4, 4, 'Financial Analyst', '2026-01-06');
CALL add_employee_project(10, 4, 'Chief Accountant', '2026-01-06');
CALL add_employee_project(5, 5, 'Marketing Specialist', '2026-03-02');
CALL add_employee_project(11, 5, 'Content Manager', '2026-03-02');
CALL add_employee_project(6, 6, 'Sales Lead', '2026-02-12');
CALL add_employee_project(12, 6, 'Sales Analyst', '2026-02-12');
CALL add_employee_project(8, 2, 'Frontend Developer', '2026-02-03');
CALL add_employee_project(13, 2, 'System Architect', '2026-02-03');
CALL add_employee_project(14, 9, 'SEO Specialist', '2026-03-13');
CALL add_employee_project(15, 6, 'Project Manager', '2026-02-12');
CALL add_employee_project(1, 7, 'Backend Developer', '2026-01-16');
CALL add_employee_project(2, 7, 'Technical Lead', '2026-01-16');
CALL add_employee_project(7, 7, 'Project Manager', '2026-01-16');
CALL add_employee_project(13, 10, 'Data Architect', '2026-01-27');
CALL add_employee_project(2, 10, 'Senior Developer', '2026-01-27');


-- STEP 3 START


DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'db_admin') THEN
        CREATE ROLE db_admin LOGIN PASSWORD 'admin123';
    ELSE
        ALTER ROLE db_admin WITH LOGIN PASSWORD 'admin123';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'db_service') THEN
        CREATE ROLE db_service LOGIN PASSWORD 'service123';
    ELSE
        ALTER ROLE db_service WITH LOGIN PASSWORD 'service123';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'db_user') THEN
        CREATE ROLE db_user LOGIN PASSWORD 'user123';
    ELSE
        ALTER ROLE db_user WITH LOGIN PASSWORD 'user123';
    END IF;
END
$$;

REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC;
REVOKE EXECUTE ON ALL ROUTINES IN SCHEMA public FROM PUBLIC;

GRANT CONNECT ON DATABASE employee_system TO db_admin, db_service, db_user;
GRANT USAGE ON SCHEMA public TO db_admin, db_service, db_user;

ALTER ROUTINE search_departments(VARCHAR) SECURITY DEFINER;
ALTER ROUTINE search_departments(VARCHAR) SET search_path TO public;

ALTER ROUTINE search_positions(VARCHAR) SECURITY DEFINER;
ALTER ROUTINE search_positions(VARCHAR) SET search_path TO public;

ALTER ROUTINE search_employees(VARCHAR) SECURITY DEFINER;
ALTER ROUTINE search_employees(VARCHAR) SET search_path TO public;

ALTER ROUTINE search_projects(VARCHAR) SECURITY DEFINER;
ALTER ROUTINE search_projects(VARCHAR) SET search_path TO public;

ALTER ROUTINE search_employee_projects(INT) SECURITY DEFINER;
ALTER ROUTINE search_employee_projects(INT) SET search_path TO public;

ALTER ROUTINE add_department(VARCHAR, VARCHAR) SECURITY DEFINER;
ALTER ROUTINE add_department(VARCHAR, VARCHAR) SET search_path TO public;

ALTER ROUTINE add_position(VARCHAR, NUMERIC) SECURITY DEFINER;
ALTER ROUTINE add_position(VARCHAR, NUMERIC) SET search_path TO public;

ALTER ROUTINE add_employee(VARCHAR, VARCHAR, VARCHAR, DATE, VARCHAR, VARCHAR, INT, INT) SECURITY DEFINER;
ALTER ROUTINE add_employee(VARCHAR, VARCHAR, VARCHAR, DATE, VARCHAR, VARCHAR, INT, INT) SET search_path TO public;

ALTER ROUTINE add_project(VARCHAR, DATE, DATE, NUMERIC) SECURITY DEFINER;
ALTER ROUTINE add_project(VARCHAR, DATE, DATE, NUMERIC) SET search_path TO public;

ALTER ROUTINE add_employee_project(INT, INT, VARCHAR, DATE) SECURITY DEFINER;
ALTER ROUTINE add_employee_project(INT, INT, VARCHAR, DATE) SET search_path TO public;

ALTER ROUTINE update_department(INT, VARCHAR, VARCHAR) SECURITY DEFINER;
ALTER ROUTINE update_department(INT, VARCHAR, VARCHAR) SET search_path TO public;

ALTER ROUTINE update_position(INT, VARCHAR, NUMERIC) SECURITY DEFINER;
ALTER ROUTINE update_position(INT, VARCHAR, NUMERIC) SET search_path TO public;

ALTER ROUTINE update_employee(INT, VARCHAR, VARCHAR, VARCHAR, DATE, VARCHAR, VARCHAR, INT, INT) SECURITY DEFINER;
ALTER ROUTINE update_employee(INT, VARCHAR, VARCHAR, VARCHAR, DATE, VARCHAR, VARCHAR, INT, INT) SET search_path TO public;

ALTER ROUTINE update_project(INT, VARCHAR, DATE, DATE, NUMERIC) SECURITY DEFINER;
ALTER ROUTINE update_project(INT, VARCHAR, DATE, DATE, NUMERIC) SET search_path TO public;

ALTER ROUTINE update_employee_project(INT, INT, INT, VARCHAR, DATE) SECURITY DEFINER;
ALTER ROUTINE update_employee_project(INT, INT, INT, VARCHAR, DATE) SET search_path TO public;

ALTER ROUTINE delete_department(INT) SECURITY DEFINER;
ALTER ROUTINE delete_department(INT) SET search_path TO public;

ALTER ROUTINE delete_position(INT) SECURITY DEFINER;
ALTER ROUTINE delete_position(INT) SET search_path TO public;

ALTER ROUTINE delete_employee(INT) SECURITY DEFINER;
ALTER ROUTINE delete_employee(INT) SET search_path TO public;

ALTER ROUTINE delete_project(INT) SECURITY DEFINER;
ALTER ROUTINE delete_project(INT) SET search_path TO public;

ALTER ROUTINE delete_employee_project(INT) SECURITY DEFINER;
ALTER ROUTINE delete_employee_project(INT) SET search_path TO public;

GRANT EXECUTE ON ALL ROUTINES IN SCHEMA public TO db_admin;

GRANT EXECUTE ON FUNCTION search_departments(VARCHAR) TO db_service, db_user;
GRANT EXECUTE ON FUNCTION search_positions(VARCHAR) TO db_service, db_user;
GRANT EXECUTE ON FUNCTION search_employees(VARCHAR) TO db_service, db_user;
GRANT EXECUTE ON FUNCTION search_projects(VARCHAR) TO db_service, db_user;
GRANT EXECUTE ON FUNCTION search_employee_projects(INT) TO db_service, db_user;

GRANT EXECUTE ON PROCEDURE add_department(VARCHAR, VARCHAR) TO db_service;
GRANT EXECUTE ON PROCEDURE add_position(VARCHAR, NUMERIC) TO db_service;
GRANT EXECUTE ON PROCEDURE add_employee(VARCHAR, VARCHAR, VARCHAR, DATE, VARCHAR, VARCHAR, INT, INT) TO db_service;
GRANT EXECUTE ON PROCEDURE add_project(VARCHAR, DATE, DATE, NUMERIC) TO db_service;
GRANT EXECUTE ON PROCEDURE add_employee_project(INT, INT, VARCHAR, DATE) TO db_service;

GRANT EXECUTE ON PROCEDURE update_department(INT, VARCHAR, VARCHAR) TO db_service;
GRANT EXECUTE ON PROCEDURE update_position(INT, VARCHAR, NUMERIC) TO db_service;
GRANT EXECUTE ON PROCEDURE update_employee(INT, VARCHAR, VARCHAR, VARCHAR, DATE, VARCHAR, VARCHAR, INT, INT) TO db_service;
GRANT EXECUTE ON PROCEDURE update_project(INT, VARCHAR, DATE, DATE, NUMERIC) TO db_service;
GRANT EXECUTE ON PROCEDURE update_employee_project(INT, INT, INT, VARCHAR, DATE) TO db_service;

-- STEP 3 END

-- STEP 4 START

-- LOG TABLES

CREATE TABLE IF NOT EXISTS departments_log (
    log_id SERIAL PRIMARY KEY,
    department_id INT,
    department_name VARCHAR(100),
    office_location VARCHAR(100),
    user_name VARCHAR(100) NOT NULL,
    update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    action VARCHAR(10) NOT NULL
);

CREATE TABLE IF NOT EXISTS positions_log (
    log_id SERIAL PRIMARY KEY,
    position_id INT,
    position_name VARCHAR(100),
    base_salary NUMERIC(10,2),
    user_name VARCHAR(100) NOT NULL,
    update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    action VARCHAR(10) NOT NULL
);

CREATE TABLE IF NOT EXISTS employees_log (
    log_id SERIAL PRIMARY KEY,
    employee_id INT,
    last_name VARCHAR(100),
    first_name VARCHAR(100),
    middle_name VARCHAR(100),
    hire_date DATE,
    email VARCHAR(150),
    phone VARCHAR(20),
    department_id INT,
    position_id INT,
    user_name VARCHAR(100) NOT NULL,
    update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    action VARCHAR(10) NOT NULL
);

CREATE TABLE IF NOT EXISTS projects_log (
    log_id SERIAL PRIMARY KEY,
    project_id INT,
    project_name VARCHAR(150),
    start_date DATE,
    end_date DATE,
    budget NUMERIC(12,2),
    user_name VARCHAR(100) NOT NULL,
    update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    action VARCHAR(10) NOT NULL
);

CREATE TABLE IF NOT EXISTS employee_projects_log (
    log_id SERIAL PRIMARY KEY,
    employee_project_id INT,
    employee_id INT,
    project_id INT,
    role_in_project VARCHAR(100),
    assigned_date DATE,
    user_name VARCHAR(100) NOT NULL,
    update_time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    action VARCHAR(10) NOT NULL
);

-- LOG FUNCTIONS

CREATE OR REPLACE FUNCTION log_departments_changes()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        INSERT INTO departments_log(department_id, department_name, office_location, user_name, update_time, action)
        VALUES (OLD.department_id, OLD.department_name, OLD.office_location, SESSION_USER, CURRENT_TIMESTAMP, TG_OP);
        RETURN OLD;
    ELSE
        INSERT INTO departments_log(department_id, department_name, office_location, user_name, update_time, action)
        VALUES (NEW.department_id, NEW.department_name, NEW.office_location, SESSION_USER, CURRENT_TIMESTAMP, TG_OP);
        RETURN NEW;
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION log_positions_changes()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        INSERT INTO positions_log(position_id, position_name, base_salary, user_name, update_time, action)
        VALUES (OLD.position_id, OLD.position_name, OLD.base_salary, SESSION_USER, CURRENT_TIMESTAMP, TG_OP);
        RETURN OLD;
    ELSE
        INSERT INTO positions_log(position_id, position_name, base_salary, user_name, update_time, action)
        VALUES (NEW.position_id, NEW.position_name, NEW.base_salary, SESSION_USER, CURRENT_TIMESTAMP, TG_OP);
        RETURN NEW;
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION log_employees_changes()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        INSERT INTO employees_log(employee_id, last_name, first_name, middle_name, hire_date, email, phone, department_id, position_id, user_name, update_time, action)
        VALUES (OLD.employee_id, OLD.last_name, OLD.first_name, OLD.middle_name, OLD.hire_date, OLD.email, OLD.phone, OLD.department_id, OLD.position_id, SESSION_USER, CURRENT_TIMESTAMP, TG_OP);
        RETURN OLD;
    ELSE
        INSERT INTO employees_log(employee_id, last_name, first_name, middle_name, hire_date, email, phone, department_id, position_id, user_name, update_time, action)
        VALUES (NEW.employee_id, NEW.last_name, NEW.first_name, NEW.middle_name, NEW.hire_date, NEW.email, NEW.phone, NEW.department_id, NEW.position_id, SESSION_USER, CURRENT_TIMESTAMP, TG_OP);
        RETURN NEW;
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION log_projects_changes()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        INSERT INTO projects_log(project_id, project_name, start_date, end_date, budget, user_name, update_time, action)
        VALUES (OLD.project_id, OLD.project_name, OLD.start_date, OLD.end_date, OLD.budget, SESSION_USER, CURRENT_TIMESTAMP, TG_OP);
        RETURN OLD;
    ELSE
        INSERT INTO projects_log(project_id, project_name, start_date, end_date, budget, user_name, update_time, action)
        VALUES (NEW.project_id, NEW.project_name, NEW.start_date, NEW.end_date, NEW.budget, SESSION_USER, CURRENT_TIMESTAMP, TG_OP);
        RETURN NEW;
    END IF;
END;
$$;

CREATE OR REPLACE FUNCTION log_employee_projects_changes()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        INSERT INTO employee_projects_log(employee_project_id, employee_id, project_id, role_in_project, assigned_date, user_name, update_time, action)
        VALUES (OLD.employee_project_id, OLD.employee_id, OLD.project_id, OLD.role_in_project, OLD.assigned_date, SESSION_USER, CURRENT_TIMESTAMP, TG_OP);
        RETURN OLD;
    ELSE
        INSERT INTO employee_projects_log(employee_project_id, employee_id, project_id, role_in_project, assigned_date, user_name, update_time, action)
        VALUES (NEW.employee_project_id, NEW.employee_id, NEW.project_id, NEW.role_in_project, NEW.assigned_date, SESSION_USER, CURRENT_TIMESTAMP, TG_OP);
        RETURN NEW;
    END IF;
END;
$$;

-- TRIGGERS

DROP TRIGGER IF EXISTS trg_departments_log ON departments;
CREATE TRIGGER trg_departments_log
AFTER INSERT OR UPDATE OR DELETE ON departments
FOR EACH ROW
EXECUTE FUNCTION log_departments_changes();

DROP TRIGGER IF EXISTS trg_positions_log ON positions;
CREATE TRIGGER trg_positions_log
AFTER INSERT OR UPDATE OR DELETE ON positions
FOR EACH ROW
EXECUTE FUNCTION log_positions_changes();

DROP TRIGGER IF EXISTS trg_employees_log ON employees;
CREATE TRIGGER trg_employees_log
AFTER INSERT OR UPDATE OR DELETE ON employees
FOR EACH ROW
EXECUTE FUNCTION log_employees_changes();

DROP TRIGGER IF EXISTS trg_projects_log ON projects;
CREATE TRIGGER trg_projects_log
AFTER INSERT OR UPDATE OR DELETE ON projects
FOR EACH ROW
EXECUTE FUNCTION log_projects_changes();

DROP TRIGGER IF EXISTS trg_employee_projects_log ON employee_projects;
CREATE TRIGGER trg_employee_projects_log
AFTER INSERT OR UPDATE OR DELETE ON employee_projects
FOR EACH ROW
EXECUTE FUNCTION log_employee_projects_changes();

-- LOG SEARCH FUNCTIONS

CREATE OR REPLACE FUNCTION search_departments_log()
RETURNS TABLE (
    log_id INT,
    department_id INT,
    department_name VARCHAR,
    office_location VARCHAR,
    user_name VARCHAR,
    update_time TIMESTAMP,
    action VARCHAR
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    SELECT l.log_id, l.department_id, l.department_name, l.office_location, l.user_name, l.update_time, l.action
    FROM departments_log l
    ORDER BY l.log_id;
END;
$$;

CREATE OR REPLACE FUNCTION search_positions_log()
RETURNS TABLE (
    log_id INT,
    position_id INT,
    position_name VARCHAR,
    base_salary NUMERIC,
    user_name VARCHAR,
    update_time TIMESTAMP,
    action VARCHAR
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    SELECT l.log_id, l.position_id, l.position_name, l.base_salary, l.user_name, l.update_time, l.action
    FROM positions_log l
    ORDER BY l.log_id;
END;
$$;

CREATE OR REPLACE FUNCTION search_employees_log()
RETURNS TABLE (
    log_id INT,
    employee_id INT,
    last_name VARCHAR,
    first_name VARCHAR,
    middle_name VARCHAR,
    hire_date DATE,
    email VARCHAR,
    phone VARCHAR,
    department_id INT,
    position_id INT,
    user_name VARCHAR,
    update_time TIMESTAMP,
    action VARCHAR
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    SELECT l.log_id, l.employee_id, l.last_name, l.first_name, l.middle_name, l.hire_date, l.email, l.phone, l.department_id, l.position_id, l.user_name, l.update_time, l.action
    FROM employees_log l
    ORDER BY l.log_id;
END;
$$;

CREATE OR REPLACE FUNCTION search_projects_log()
RETURNS TABLE (
    log_id INT,
    project_id INT,
    project_name VARCHAR,
    start_date DATE,
    end_date DATE,
    budget NUMERIC,
    user_name VARCHAR,
    update_time TIMESTAMP,
    action VARCHAR
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    SELECT l.log_id, l.project_id, l.project_name, l.start_date, l.end_date, l.budget, l.user_name, l.update_time, l.action
    FROM projects_log l
    ORDER BY l.log_id;
END;
$$;

CREATE OR REPLACE FUNCTION search_employee_projects_log()
RETURNS TABLE (
    log_id INT,
    employee_project_id INT,
    employee_id INT,
    project_id INT,
    role_in_project VARCHAR,
    assigned_date DATE,
    user_name VARCHAR,
    update_time TIMESTAMP,
    action VARCHAR
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
    RETURN QUERY
    SELECT l.log_id, l.employee_project_id, l.employee_id, l.project_id, l.role_in_project, l.assigned_date, l.user_name, l.update_time, l.action
    FROM employee_projects_log l
    ORDER BY l.log_id;
END;
$$;

REVOKE EXECUTE ON FUNCTION search_departments_log() FROM PUBLIC, db_service, db_user;
REVOKE EXECUTE ON FUNCTION search_positions_log() FROM PUBLIC, db_service, db_user;
REVOKE EXECUTE ON FUNCTION search_employees_log() FROM PUBLIC, db_service, db_user;
REVOKE EXECUTE ON FUNCTION search_projects_log() FROM PUBLIC, db_service, db_user;
REVOKE EXECUTE ON FUNCTION search_employee_projects_log() FROM PUBLIC, db_service, db_user;

GRANT EXECUTE ON FUNCTION search_departments_log() TO db_admin;
GRANT EXECUTE ON FUNCTION search_positions_log() TO db_admin;
GRANT EXECUTE ON FUNCTION search_employees_log() TO db_admin;
GRANT EXECUTE ON FUNCTION search_projects_log() TO db_admin;
GRANT EXECUTE ON FUNCTION search_employee_projects_log() TO db_admin;

-- STEP 4 END
