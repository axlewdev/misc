
"Customer(name) has many Order(desc)" implementation.

SQLite Schema:

CREATE TABLE customers (
  id INTEGER PRIMARY KEY NOT NULL,
  name varchar NOT NULL
);
CREATE TABLE orders (
  id INTEGER PRIMARY KEY NOT NULL,
  desc varchar,
  customer  NOT NULL,
  FOREIGN KEY (customer) REFERENCES customers(id) ON DELETE CASCADE ON UPDATE CASCADE
);
CREATE UNIQUE INDEX customers_name ON customers (name);
CREATE INDEX orders_idx_customer ON orders (customer);


Running application:

<root_project># morbo app_start.pl # SQLite schema and population will be created.

Population:

sqlite> select * from customers;
1|Boris
2|James

sqlite> select * from orders;
1|Boris order 1|1
2|Boris order 2|1
3|James order 1|2
4|James order 2|2

Testing:

<root_project># prove -I ./ ./t



