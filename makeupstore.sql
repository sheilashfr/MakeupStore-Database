create database makeupstore;
use makeupstore;

##Create Tables

#Customer info table showing list of customer details
CREATE TABLE Customer_info (
	Cust_id INT NOT NULL,
	First_name CHAR(25) NOT NULL,
	Last_name VARCHAR(25) NOT NULL,
	Email_address VARCHAR(25) NOT NULL,
	PRIMARY KEY (Cust_id)
);

#Orders table showing list of orders 
CREATE TABLE Orders (
	Order_id INT NOT NULL,
    Cust_id INT NOT NULL,
    Order_date DATE NOT NULL,
    Shipping_address VARCHAR(50) NOT NULL,
    PRIMARY KEY (Order_id),
    FOREIGN KEY (Cust_id) REFERENCES Customer_info(Cust_id)
);

#Order details table showing details of every order 
CREATE TABLE Order_details(
	Order_details_id INT NOT NULL,
    Order_id INT NOT NULL,
    Product_id INT NOT NULL,
    Product_qty DECIMAL NOT NULL,
    Price DECIMAL NOT NULL,
    PRIMARY KEY (Order_details_id),
    FOREIGN KEY (Order_id) REFERENCES Orders(Order_id),
    FOREIGN KEY (Product_id) REFERENCES Products(Product_id)
  ); 

#Products table showing list of products
CREATE TABLE Products (
	Product_id INT NOT NULL UNIQUE,
	Product_name VARCHAR(30) NOT NULL,
	Price DECIMAL,
	Category VARCHAR(20) NOT NULL,
	PRIMARY KEY (Product_id)
);

Alter table Order_details
Add Sub_total decimal not null;

Alter table products
Add Brand VARCHAR(20);

#Supplier table showing list of supplier of products
CREATE TABLE Supplier (
	Supplier_id varchar(8) not null,
	Supplier_name VARCHAR(8) NOT NULL,
	Brand VARCHAR(20),
    PRIMARY KEY (Supplier_id)
);

#Inserting product data
Insert into Products
(Product_id, Product_name, Price, Category, Brand)
Values
(01, 'Waterproof Mascara', 10.00, 'Eyes', 'About eyes'),
(02, 'Smudge-proof Lip Stain', 12.00, 'Lips', 'Smooch'),
(03, 'Full Coverage Foundie', 16.00, 'Face', 'Flawless'),
(04, 'Matte Powder', 14.00, 'Face', 'Flawless'),
(05, 'Black Eyeliner', 12.00, 'Eyes', 'Flawless'),
(06, 'Pink Matte Lipstick',11.00, 'Lips', 'Smooch'),
(07, 'Clear Lipgloss', 10.00, 'Lips', 'Smooch');
Insert into Products
(Product_id, Product_name, Price, Category, Brand)
Values
(08, 'Illuminating Bronzer', 12.00, 'Face', 'Flawless');

Insert into Customer_info
(Cust_id, First_name, Last_name, Email_address)
Values
(01, 'Sheila', 'Shafira', 'sheilashafira[at]mail.com'),
(02, 'Darian', 'Irani', 'darianirani[at]mail.com'),
(03, 'Anindya', 'Alya', 'anindyaalya[at]mail.com'),
(04, 'Dewi', 'Damayanti', 'ddamayanti[at]mail.com');

Alter table Order_details drop price; 
Alter table order_details drop sub_total;

Insert into Orders
(Order_id, Cust_id, Order_date, Shipping_Address)
Values
(1001, 03, '2022-10-30', 'Old bridewell 5, BS12AB'),
(1002, 02, '2022-11-01', 'Cromwell Street 9, SW13AX'),
(1003, 01, '2022-11-02', 'Denmark Road 10, SW13BE'),
(1004, 04, '2022-11-02', 'Stoke Park 2, BS189ER');


Insert into Order_details
(Order_details_id, Order_id, Product_id, Product_qty)
Value
(001, 1001, 03, 01),
(002, 1001, 01, 01),
(003, 1002, 04, 02),
(004, 1003, 07, 01),
(005, 1004, 05, 01),
(006, 1004, 02, 02),
(007, 1004, 01, 01);
UPDATE order_details SET priceEach = '10.00' where product_id='01';
UPDATE order_details SET priceEach = '12.00' where product_id='02';
UPDATE order_details SET priceEach = '16.00' where product_id='03';
UPDATE order_details SET priceEach = '14.00' where product_id='04';
UPDATE order_details SET priceEach = '12.00' where product_id='05';
UPDATE order_details SET priceEach = '11.00' where product_id='06';
UPDATE order_details SET priceEach = '10.00' where product_id='07';

#Setting sql modes
set sql_safe_updates=0;
set sql_mode=0;

----------
##show grandtotal
create or replace view grandtotal as
select distinct order_id, sum(product_qty*priceEach) as subtotal
from order_details
group by order_id;
select * from grandtotal;

##show orders info of grandtotal and shipping address (create view + use join)
create or replace view orders_list as
select distinct b.order_id, a.subtotal, b.cust_id, b.shipping_address
from grandtotal a
inner join orders b on a.order_id = b.order_id
group by order_id;
select * from orders_list

#Create function of 20% discount for item over £12
use makeupstore
DELIMITER //
CREATE FUNCTION Discounted_Items(price DECIMAL) 
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE Discount VARCHAR(20);
    IF price >= 12.00 THEN
        SET Discount = 'YES';
    ELSEIF price < 12.00 THEN
        SET Discount = 'NO';
    END IF;
    RETURN Discount;
END//price
DELIMITER ;

select * from Products;
select Product_id, Product_name, Price, Discounted_Items(Price) as Discount from products;


#Example query with subquery
select a.order_id, a.cust_id, b.first_name, b.Last_name, a.subtotal
from orders_list a
inner join customer_info b on a.cust_id = b.cust_id
where subtotal >= 35;






