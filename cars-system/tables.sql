create table if not exists auth_user
(
    id          bigserial                not null,
    username    varchar(30)              not null,
    password    varchar(128)             not null,
    is_employee boolean                  not null,
    is_company  boolean                  not null,
    created_at  timestamp with time zone not null,
    updated_at  timestamp with time zone null,
    constraint auth_user_id primary key (id)
);

create table if not exists addresses
(
    id         bigserial                not null,
    auth_id    bigint                   not null,
    country    bigint                   not null,
    city       varchar(30)              not null,
    street     varchar(30)              not null,
    zip        varchar(10)              not null,
    created_at timestamp with time zone not null,
    updated_at timestamp with time zone null,
    constraint customer_address_id primary key (id),
    constraint customer_address_customer_id foreign key (auth_id) references auth_user (id)
);

create table if not exists customers
(
    id         bigserial                not null,
    auth_id    bigint                   not null,
    first_name varchar(30)              not null,
    last_name  varchar(30)              not null,
    email      varchar(30)              not null,
    phone      varchar(30)              not null,
    created_at timestamp with time zone not null,
    updated_at timestamp with time zone null,
    constraint customers_id primary key (id),
    constraint customers_auth_id foreign key (auth_id) references auth_user (id)
);

create table if not exists companies
(
    id            bigserial                not null,
    auth_id       bigint                   not null,
    company_name  varchar(30)              not null,
    contact_email varchar(30)              not null,
    company_phone varchar(30)              not null,
    contact_phone varchar(30)              not null,
    created_at    timestamp with time zone not null,
    updated_at    timestamp with time zone null,
    constraint companies_id primary key (id),
    constraint companies_auth_id foreign key (auth_id) references auth_user (id)
);

create table if not exists employees
(
    id         bigserial                not null,
    auth_id    bigint                   not null,
    first_name varchar(30)              not null,
    last_name  varchar(30)              not null,
    email      varchar(30)              not null,
    phone      varchar(30)              not null,
    work_type  varchar(30)              not null,
    created_at timestamp with time zone not null,
    updated_at timestamp with time zone null,
    constraint employees_id primary key (id),
    constraint employees_auth_id foreign key (auth_id) references auth_user (id)
);

create table if not exists car_service_shops
(
    id         bigserial                not null,
    country    varchar(30)              not null,
    city       varchar(30)              not null,
    street     varchar(30)              not null,
    zip        varchar(10)              not null,
    is_billing boolean                  not null,
    created_at timestamp with time zone not null,
    updated_at timestamp with time zone null,
    constraint car_service_shops_id primary key (id)
);

create table if not exists banned_users
(
    id           bigserial                not null,
    auth_id      bigint                   not null,
    reason       text                     not null,
    is_permanent boolean                  not null,
    banned_until timestamp with time zone not null,
    ban_count    bigint                   not null,
    created_at   timestamp with time zone not null,
    updated_at   timestamp with time zone null,
    constraint banned_users_id primary key (id),
    constraint banned_users_auth_id foreign key (auth_id) references auth_user (id)
);

create table if not exists payments
(
    id                 bigserial                not null,
    auth_id            bigint                   not null,
    amount             numeric(10, 2)           not null,
    payment_type       varchar(255)             not null,
    billing_address_id bigint                   null,
    paid_at            timestamp with time zone not null,
    created_at         timestamp with time zone not null,
    updated_at         timestamp with time zone null,
    constraint payments_id primary key (id),
    constraint payments_auth_id foreign key (auth_id) references auth_user (id),
    constraint payments_billing_address_id foreign key (billing_address_id) references addresses (id)
);

create table if not exists cars
(
    id         bigserial                not null,
    brand      varchar(30)              not null,
    model      varchar(30)              not null,
    year       varchar(30)              not null,
    color      varchar(30)              not null,
    added_by   bigint                   not null,
    to_rent    boolean                  not null,
    created_at timestamp with time zone not null,
    updated_at timestamp with time zone null,
    constraint cars_id primary key (id),
    constraint cars_employee_id foreign key (added_by) references employees (id)
);

create table if not exists cars_to_sell
(
    id         bigserial                not null,
    shop_id    bigint                   not null,
    car_id     bigint                   not null,
    created_at timestamp with time zone not null,
    updated_at timestamp with time zone null,
    constraint cars_to_sell_id primary key (id),
    constraint cars_shop_id foreign key (shop_id) references car_service_shops (id),
    constraint cars_to_sell_car_id foreign key (car_id) references cars (id)
);

create table if not exists cars_to_rent
(
    id         bigserial                not null,
    shop_id    bigint                   not null,
    car_id     bigint                   not null,
    created_at timestamp with time zone not null,
    updated_at timestamp with time zone null,
    constraint cars_to_rent_id primary key (id),
    constraint cars_shop_id foreign key (shop_id) references car_service_shops (id),
    constraint cars_to_rent_car_id foreign key (car_id) references cars (id)
);

create table if not exists car_rental_category
(
    id               bigserial                not null,
    car_id           bigint                   not null,
    price_daily_from numeric(10, 2)           not null,
    price_daily_to   numeric(10, 2)           not null,
    created_at       timestamp with time zone not null,
    updated_at       timestamp with time zone null,
    constraint car_rental_category_id primary key (id),
    constraint car_rental_category_car_id foreign key (car_id) references cars_to_rent (id)
);

create table if not exists car_sell_category
(
    id         bigserial                not null,
    car_id     bigint                   not null,
    price_from numeric(10, 2)           not null,
    price_to   numeric(10, 2)           not null,
    created_at timestamp with time zone not null,
    updated_at timestamp with time zone null,
    constraint car_sell_category_id primary key (id),
    constraint car_sell_category_car_id foreign key (car_id) references cars_to_sell (id)
);

create table if not exists sell_pricing
(
    id          bigserial                not null,
    car_id      bigint                   not null,
    price       numeric(10, 2)           null,
    category_id bigint                   null,
    created_at  timestamp with time zone not null,
    updated_at  timestamp with time zone null,
    constraint sell_pricing_id primary key (id),
    constraint pricing_car_id foreign key (car_id) references cars_to_sell (id),
    constraint pricing_category_id foreign key (category_id) references car_sell_category (id)
);

create table if not exists rent_pricing
(
    id            bigserial                not null,
    car_id        bigint                   not null,
    category_id   bigint                   null,
    price_per_day numeric(10, 2)           null,
    created_at    timestamp with time zone not null,
    updated_at    timestamp with time zone null,
    constraint rent_pricing_id primary key (id),
    constraint pricing_car_id foreign key (car_id) references cars_to_rent (id),
    constraint pricing_category_id foreign key (category_id) references car_rental_category (id)
);

create table if not exists cars_rental
(
    id         bigserial                not null,
    car_id     bigint                   not null,
    auth_id    bigint                   not null,
    rent_from  timestamp with time zone not null,
    rent_to    timestamp with time zone not null,
    amount     numeric(10, 2)           not null,
    created_at timestamp with time zone not null,
    updated_at timestamp with time zone null,
    constraint cars_rental_id primary key (id),
    constraint cars_rental_car_id foreign key (car_id) references cars_to_rent (id),
    constraint cars_rental_employee_id foreign key (auth_id) references auth_user (id)
);

create table if not exists cars_sold
(
    id         bigserial                not null,
    car_id     bigint                   not null,
    auth_id    bigint                   not null,
    sold_at    timestamp with time zone not null,
    amount     numeric(10, 2)           not null,
    created_at timestamp with time zone not null,
    updated_at timestamp with time zone null,
    constraint cars_sold_id primary key (id),
    constraint cars_sold_car_id foreign key (car_id) references cars_to_sell (id),
    constraint cars_sold_auth_id foreign key (auth_id) references auth_user (id)
);

create table if not exists employees_rent_discount
(
    id               bigserial                not null,
    employee_id      bigint                   not null,
    discount_per_day numeric(10, 2)           not null,
    created_at       timestamp with time zone not null,
    updated_at       timestamp with time zone null,
    constraint employees_rent_discount_id primary key (id),
    constraint employees_discount_employee_id foreign key (employee_id) references employees (id)
);

create table if not exists employees_sell_discount
(
    id          bigserial                not null,
    employee_id bigint                   not null,
    discount    numeric(10, 2)           not null,
    created_at  timestamp with time zone not null,
    updated_at  timestamp with time zone null,
    constraint employees_sell_discount_id primary key (id),
    constraint employees_discount_employee_id foreign key (employee_id) references employees (id)
);

create table if not exists companies_rent_discount
(
    id               bigserial                not null,
    company_id       bigint                   not null,
    discount_per_day numeric(10, 2)           not null,
    created_at       timestamp with time zone not null,
    updated_at       timestamp with time zone null,
    constraint companies_rent_discount_id primary key (id),
    constraint companies_discount_company_id foreign key (company_id) references companies (id)
);

create table if not exists companies_sell_discount
(
    id         bigserial                not null,
    company_id bigint                   not null,
    discount   numeric(10, 2)           not null,
    created_at timestamp with time zone not null,
    updated_at timestamp with time zone null,
    constraint companies_sell_discount_id primary key (id),
    constraint companies_discount_company_id foreign key (company_id) references companies (id)
);

create table if not exists customers_rent_discount
(
    id               bigserial                not null,
    customer_id      bigint                   not null,
    discount_per_day numeric(10, 2)           not null,
    created_at       timestamp with time zone not null,
    updated_at       timestamp with time zone null,
    constraint customers_rent_discount_id primary key (id),
    constraint customers_discount_customer_id foreign key (customer_id) references customers (id)
);

create table if not exists customers_sell_discount
(
    id          bigserial                not null,
    customer_id bigint                   not null,
    discount    numeric(10, 2)           not null,
    created_at  timestamp with time zone not null,
    updated_at  timestamp with time zone null,
    constraint customers_sell_discount_id primary key (id),
    constraint customers_discount_customer_id foreign key (customer_id) references customers (id)
);

create table if not exists car_rental_checkup
(
    id                bigserial                not null,
    car_id            bigint                   not null,
    last_checkup_date timestamp with time zone not null,
    need_repair       boolean                  not null,
    created_at        timestamp with time zone not null,
    updated_at        timestamp with time zone null,
    constraint car_rental_checkup_id primary key (id),
    constraint car_rental_checkup_car_id foreign key (car_id) references cars_to_rent (id)
);

create table if not exists car_rental_repair
(
    id          bigserial                not null,
    car_id      bigint                   not null,
    problem     text                     not null,
    repair_date timestamp with time zone not null,
    repair_cost numeric(10, 2)           not null,
    created_at  timestamp with time zone not null,
    updated_at  timestamp with time zone null,
    constraint cat_rental_repair_id primary key (id),
    constraint cat_rental_repair_car_id foreign key (car_id) references cars_to_rent (id)
);
