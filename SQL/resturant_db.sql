CREATE DATABASE restaurant;

USE restaurant

CREATE TABLE tbl( 

    table_id INT, 

    location VARCHAR(255), 

    PRIMARY KEY (table_id) 

); 

CREATE TABLE waiter( 

    waiter_id INT, 

    name VARCHAR(150), 

    contact_no VARCHAR(10), 

    shift VARCHAR(10), 

    PRIMARY KEY (waiter_id) 

); 


CREATE TABLE table_order( 

    order_id INT, 

    date_time DATETIME, 

    table_id INT, 

    waiter_id INT, 

    PRIMARY KEY (order_id), 

    FOREIGN KEY (table_id) REFERENCES tbl(table_id), 

    FOREIGN KEY (waiter_id) REFERENCES waiter(waiter_id) 

); 


CREATE TABLE customer( 

    customer_id INT, 

    name VARCHAR(100), 

    NIC_no VARCHAR(12), 

    contact_no VARCHAR(10), 

    PRIMARY KEY (customer_id) 

); 


CREATE TABLE reservation( 

    reservation_id INT, 

    date_time DATETIME, 

    no_of_pax INT, 

    order_id INT, 

    table_id INT, 

    customer_id INT, 

    PRIMARY KEY (reservation_id), 

    FOREIGN KEY (order_id) REFERENCES tbl(table_id), 

    FOREIGN KEY (table_id) REFERENCES tbl(table_id), 

    FOREIGN KEY (customer_id) REFERENCES customer(customer_id) 

); 


CREATE TABLE menu( 

    menu_id INT, 

    description VARCHAR(255), 

    availability INT, 

    PRIMARY KEY (menu_id) 

); 


CREATE TABLE menu_item( 

    menu_item_id INT, 

    description VARCHAR(255), 

    price FLOAT, 

    availability INT, 

    menu_id INT, 

    PRIMARY KEY (menu_item_id), 

    FOREIGN KEY (menu_id) REFERENCES menu(menu_id) 

); 

CREATE TABLE order_menu_item( 

    order_id INT, 

    menu_item_id INT, 

    quantity INT, 

    PRIMARY KEY (order_id,menu_item_id), 

    FOREIGN KEY (order_id) REFERENCES table_order(order_id), 

    FOREIGN KEY (menu_item_id) REFERENCES menu_item(menu_item_id) 

); 

