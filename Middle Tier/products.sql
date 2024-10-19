-- Create the products table
CREATE TABLE products (
    product_id INT PRIMARY KEY IDENTITY,
    product_name VARCHAR(100) NOT NULL,
    product_description VARCHAR(255),
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity INT NOT NULL,
    category VARCHAR(50)
);

-- Insert dummy data into the products table
INSERT INTO products (product_name, product_description, price, stock_quantity, category)
VALUES 
('Toy Car', 'A small toy car for children', 9.99, 100, 'Toys'),
('Laptop', 'A high-performance laptop', 999.99, 50, 'Electronics'),
('Coffee Mug', 'A ceramic coffee mug', 4.99, 200, 'Kitchenware'),
('Notebook', 'A spiral-bound notebook', 2.99, 150, 'Stationery'),
('Headphones', 'Noise-cancelling headphones', 199.99, 75, 'Electronics');

-- Select all data from the products table to verify the insertion
SELECT * FROM products;