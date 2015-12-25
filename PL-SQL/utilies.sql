


-------------------------SEQUENCES---------------------
/*purchase_seq is a sequence for purchase that*/ 
/*has max value 999999. After this value, it should cycle and*/ /*values should be in order*/ 
	create sequence purchase_seq
	increment by 1
    start with 100015
    maxvalue 999999
    cycle
    order
    /

/*supply_seq is a sequence for supply that*/
/*has max value 9999. After this value, it should */
/*cycle and values should be in order*/ 
	create sequence supply_seq
    increment by 1
	start with 1010
    maxvalue 9999
    cycle
	order
    /
	
/*logs_seq is a sequence for logs that*/
/*has max value 99999. After this value, it should */
/*cycle and values should be in order*/ 
	create sequence logs_seq
	increment by 1
	start with 10000
	maxvalue 99999
	cycle
	order
	/








--------------Triggers------------------------:   

/*purchase_logs is a trigger to insert a tuple */
/*into logs table everytime we insert a tuple */
/*into purchases table. We have taken curr_date as */
/*a local variable to convert sysdate into desired format*/   
create or replace trigger purchases_logs 
after insert on purchases
declare
curr_date logs.otime%type;
begin
Select to_char(sysdate, 'dd-mon-yy') into curr_date from dual;
insert into logs values(logs_seq.nextval,user,curr_date,'purchases','insert',purchase_seq.currval);
end;
/
show error;

/*products_logs is a trigger to insert a tuple */
/*into logs table everytime we update QOH value of a product.*/
/*We have taken curr_date as a local variable*/
/*to convert sysdate into desired format*/   
create or replace trigger products_logs
after update of QOH on products
for each row
declare
curr_date logs.otime%type;
begin
Select to_char(sysdate, 'dd-mon-yy') into curr_date from dual;
insert into logs values(logs_seq.nextval,user,curr_date,'products','update',:new.pid);
end;
/
show error;

/*customers_logs is a trigger to insert a tuple*/
/*into logs table everytime we update visits_made value*/
/*of a customer. I have taken curr_date as a local variable*/
/*to convert sysdate into desired format*/   
create or replace trigger customers_logs
after update of visits_made on customers
for each row
declare
curr_date logs.otime%type;
begin
Select to_char(sysdate, 'dd-mon-yy') into curr_date from dual;
insert into logs values(logs_seq.nextval,user,curr_date,'customers','update',:new.cid);
end;
/
show error;

/*supply_logs is a trigger to insert a tuple */
/*into logs table everytime we insert a tuple */
/*into a supply table. I have taken curr_date*/ 
/*as a local variable to convert sysdate into desired format*/   
create or replace trigger supply_logs 
after insert on supply
declare
curr_date logs.otime%type;
begin
Select to_char(sysdate, 'dd-mon-yy') into curr_date from dual;
insert into logs values(logs_seq.nextval,user,curr_date,'supply','insert',supply_seq.currval);
end;
/
show error;


/*update_qoh is a trigger that would update qoh value*/
/*of a product everytime we insert a tuple in purchases table*/
/*We select the last entry from purchase table. */
/*update the qoh field of products. Now we compare*/
/*qoh value with qoh_threshold.If it is less, */
/*we display a message that qoh is less than threshold.*/
/*We calculate M = threshold - qoh + 1*/
/*we calculate quantity of product to be ordered*/
/*using the formula quantity=10+M+qoh*/
/*We also insert data into supply based on conditions given*/
/*Now we add this ordered quantity with */
/*existing qoh in products*/
/*We also display new qoh. Now we compare last_visit_date of */
/*customer with date entered while inserting into */
/*purchases. If it is same, we just increment visits_made by 1*/
/*else we also update last_visit_date apart from incrementing*/
/*visits_made by 1*/ 
create or replace trigger update_qoh
after insert on purchases
declare
purno purchases.pur#%type;
prod_id purchases.pid%type;
cust_id customers.cid%type;
prod_qty purchases.qty%type;
supply_id supply.sid%type;
curr_date supply.sdate%type;
M purchases.qty%type;
quanti supply.quantity%type;
new_qoh products.qoh%type;
original_threshold products. qoh_threshold%type;
newval products.qoh%type;
last_time purchases.ptime%type;
lvd customers.last_visit_date%type;
vm customers.visits_made%type;

begin
Select to_char(sysdate, 'dd-mon-yy') into curr_date from dual;
select pur#,pid,cid,qty,ptime into purno,prod_id,cust_id,prod_qty,last_time from purchases group by pur#,pid,cid,qty,ptime having pur#=(select max(pur#) from purchases);
update products set qoh = (qoh - prod_qty) where products.pid=prod_id;
select qoh,qoh_threshold into new_qoh,original_threshold from products where products.pid=prod_id;
if(new_qoh < original_threshold) then
dbms_output.put_line('Current QOH of the product is below  the required threshold');
M := original_threshold - new_qoh +1 ;
quanti := 10 + M + new_qoh;
select min(sid) into supply_id from supply where supply.pid=prod_id;
insert into supply values(supply_seq.nextval,prod_id,supply_id,curr_date,quanti);
update products set qoh = (qoh + quanti) where products.pid= prod_id;
select qoh into newval from products where products.pid = prod_id;
dbms_output.put_line('New QOH: ' || newval);
select visits_made,last_visit_date into vm,lvd from customers where customers.cid = cust_id ;
if(last_time<>lvd) then
update customers set visits_made=vm + 1 where customers.cid=cust_id;
update customers set  last_visit_date = last_time where customers.cid=cust_id;
else
update customers set visits_made=vm + 1 where customers.cid=cust_id;
end if;
end if;
end;
/
show error;
