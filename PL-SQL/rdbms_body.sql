	set serveroutput on
CREATE OR REPLACE PACKAGE BODY RBMS_PACKAGE AS


/*procedure to display all the products*/
PROCEDURE show_products(products_cur OUT srs_cursor) IS
BEGIN
	open products_cur for
	select * from products;
END show_products;

/*procedure to display all the purchases*/
PROCEDURE show_purchases(purchases_cur OUT srs_cursor) IS
BEGIN
	open purchases_cur for
	select * from purchases order by pur#;
END show_purchases;

/*procedure to display all the employees*/
PROCEDURE show_employees(employees_cur OUT srs_cursor) IS
BEGIN
	open employees_cur for
	select * from employees order by eid;
END show_employees;

/*procedure to display all the customers*/
PROCEDURE show_customers(customers_cur OUT srs_cursor) IS
BEGIN
	open customers_cur for
	select * from customers;
END show_customers;

/*procedure to display all the Suppliers*/
PROCEDURE show_suppliers(suppliers_cur OUT srs_cursor) IS
BEGIN
	open suppliers_cur for
	select * from suppliers;
END show_suppliers;

/*procedure to display all the supply*/
PROCEDURE show_supply(supply_cur OUT srs_cursor) IS
BEGIN
	open supply_cur for
	select * from supply order by sup#;
END show_supply;


/*procedure to display all the logs*/
PROCEDURE show_logs(logs_cur OUT srs_cursor) IS
BEGIN
open logs_cur for
select * from logs order by log#;END show_logs;


/*procedure to add a new products */
/* execute  RBMS_PACKAGE.add_products('p016', 'dsadsa', 45,4,8.33,0.3) */
procedure add_products(v_pid in products.pid%type, v_pname in products.pname%type, v_qoh in products.qoh%type, 
v_qoh_threshold in products.qoh_threshold%type, v_original_price in products.original_price%type, v_discnt_rate in products.discnt_rate%type) is

begin
insert into products values(v_pid, v_pname, v_qoh, v_qoh_threshold, v_original_price, v_discnt_rate);
END add_products;



/*procedure to add a new purchases */
/* execute  RBMS_PACKAGE.add_purchases('e01', 'p001', 'c001',200) */

procedure add_purchases(v_eid in purchases.eid%type, v_pid in purchases.pid%type,
 v_cid in purchases.cid%type, v_qty in purchases.qty%type, printoutput OUT varchar) is 
 
v_date date;
 v_total_price number(7,2);
 v_pur# number(6);
 total_qoh number(5);
 oprice number(6,2);
 discount  number(3,2);

 

BEGIN
v_date:=SYSDATE;

SELECT ORIGINAL_PRICE, DISCNT_RATE into oprice,discount FROM PRODUCTS WHERE PID = v_pid;
 v_total_price:=(oprice*(1-discount))* v_qty;
select qoh into total_qoh from products where pid = v_pid;
 
if  (total_qoh-v_qty)>=0 then
 
 v_pur#:=purchase_seq.nextval;
 insert into purchases values (v_pur#,v_eid,v_pid,v_cid, v_qty, v_date, v_total_price);
 -----------dbms_output.put_line('Purchase Successful');
 printoutput:='Purchase Successful';

 end if;
if  (total_qoh-v_qty)<0 then
 ---------dbms_output.put_line('Insufficient quantity in stock, the purchase request is rejected');
  printoutput:='Insufficient quantity in stock, the purchase request is rejected';

  end if;
 END add_purchases;

  
 /*procedure to Report Monthly Sales */
 /*execute  RBMS_PACKAGE.get_product_info('p001')*/ 
 /*It takes prod_pid as input*/
 procedure get_product_info(prod_pid in purchases.pid%type, c1 OUT srs_cursor) as
 BEGIN
      open  c1 for 
select products.pname as PNAME,to_char(purchases.ptime,'MON')as PMON,to_char(purchases.ptime,'YYYY')as PYEAR,sum(purchases.qty)as TOTALMON,sum(purchases.total_price)as TOTAL
         , sum(purchases.total_price) / sum(purchases.qty) as AVG_MONTH from purchases , products 
        where purchases.pid=products.pid AND   purchases.pid=prod_pid group by to_char(purchases.ptime,'MON'),to_char(purchases.ptime,'YYYY'),products.pname;
       
   end get_product_info;

   
END; /* end of the package body */
/
show error;


