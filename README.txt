
# SQLite Schema

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
