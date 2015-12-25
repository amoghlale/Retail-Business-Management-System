CREATE OR REPLACE PACKAGE RBMS_PACKAGE AS
TYPE srs_cursor IS REF CURSOR;


/*procedures to display all the 6 Tables*/
PROCEDURE show_products(products_cur OUT srs_cursor);
PROCEDURE show_purchases(purchases_cur OUT srs_cursor);
PROCEDURE show_employees(employees_cur OUT srs_cursor);
PROCEDURE show_customers(customers_cur OUT srs_cursor);
PROCEDURE show_suppliers(suppliers_cur OUT srs_cursor);
PROCEDURE show_supply(supply_cur OUT srs_cursor);
PROCEDURE show_logs(logs_cur OUT srs_cursor);


/*Procedure to add products*/
procedure add_products(v_pid in products.pid%type, v_pname in products.pname%type, v_qoh in products.qoh%type, v_qoh_threshold in products.qoh_threshold%type, v_original_price in products.original_price%type, v_discnt_rate in products.discnt_rate%type);

/*Procedure to add purchases*/
procedure add_purchases(v_eid in purchases.eid%type, v_pid in purchases.pid%type,
 v_cid in purchases.cid%type, v_qty in purchases.qty%type, printoutput OUT varchar);

/*Procedure to report monthly sale information of a product*/procedure get_product_info(prod_pid in purchases.pid%type, c1 OUT srs_cursor);
END;
/
show errors;