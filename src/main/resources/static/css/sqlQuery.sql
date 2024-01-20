----------tbl_company---------
-- Table: public.company

-- DROP TABLE IF EXISTS public.company;

CREATE TABLE IF NOT EXISTS public.company
(
    id bigint NOT NULL GENERATED ALWAYS AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1 ),
    companyname character varying(50) COLLATE pg_catalog."default" NOT NULL,
    address character varying(500) COLLATE pg_catalog."default" NOT NULL,
    phoneno character varying(15) COLLATE pg_catalog."default",
    statename character varying(50) COLLATE pg_catalog."default",
    createddate timestamp with time zone,
    companygstno character varying(50) COLLATE pg_catalog."default",
    companytype character varying(30) COLLATE pg_catalog."default",
    companypannumber character varying(50) COLLATE pg_catalog."default",
    CONSTRAINT company_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.company
    OWNER to postgres;

---------tbl_product------------
-- Table: public.tbl_product

-- DROP TABLE IF EXISTS public.tbl_product;

CREATE SEQUENCE tbl_product_id_seq;

CREATE TABLE IF NOT EXISTS public.tbl_product
(
    id integer NOT NULL DEFAULT nextval('tbl_product_id_seq'::regclass),
    productname character varying(70) COLLATE pg_catalog."default",
    sellingprice double precision,
    costprice double precision,
    producthsn character varying(50) COLLATE pg_catalog."default",
    gsttype character varying(40) COLLATE pg_catalog."default",
    producttype character varying(50) COLLATE pg_catalog."default",
    createddate timestamp without time zone,
    CONSTRAINT tbl_product_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.tbl_product
    OWNER to postgres;
--------------------tbl_productstock--------------------
-- Table: public.tbl_productstock

-- DROP TABLE IF EXISTS public.tbl_productstock;

CREATE TABLE IF NOT EXISTS public.tbl_productstock
(
    id bigint NOT NULL GENERATED BY DEFAULT AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1 ),
    productname character varying COLLATE pg_catalog."default",
    totalstock double precision,
    createddate timestamp without time zone,
    productid integer,
    CONSTRAINT tbl_productstock_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.tbl_productstock
    OWNER to postgres;
------------------tbl_salesordercompany------------
-- Table: public.tbl_salesordercompany

-- DROP TABLE IF EXISTS public.tbl_salesordercompany;

CREATE TABLE IF NOT EXISTS public.tbl_salesordercompany
(
    id bigint NOT NULL GENERATED BY DEFAULT AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1 ),
    orderdate timestamp without time zone NOT NULL,
    voucherno character varying COLLATE pg_catalog."default" NOT NULL,
    companyname character varying COLLATE pg_catalog."default" NOT NULL,
    totalamount double precision NOT NULL,
    totaltaxamount double precision NOT NULL,
    totaltaxableamount double precision NOT NULL,
    createddate timestamp without time zone,
    gsttype character varying COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT tbl_salesorderproductdetails_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.tbl_salesordercompany
    OWNER to postgres;
--------------------tbl_salesproductdetails-------------------
-- Table: public.tbl_salesorderproductdetails

-- DROP TABLE IF EXISTS public.tbl_salesorderproductdetails;

CREATE TABLE IF NOT EXISTS public.tbl_salesorderproductdetails
(
    id bigint NOT NULL GENERATED BY DEFAULT AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1 ),
    productname character varying COLLATE pg_catalog."default" NOT NULL,
    producttype character varying COLLATE pg_catalog."default" NOT NULL,
    quantity double precision NOT NULL,
    price double precision NOT NULL,
    total double precision NOT NULL,
    createddate timestamp without time zone,
    salesordercompanyid bigint NOT NULL,
    CONSTRAINT tbl_salesorderproductdetails_pkey1 PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.tbl_salesorderproductdetails
    OWNER to postgres;
-----------------tbl_vendor_payment------------------
-- Table: public.tbl_vendor_payment

-- DROP TABLE IF EXISTS public.tbl_vendor_payment;

CREATE TABLE IF NOT EXISTS public.tbl_vendor_payment
(
    id bigint NOT NULL GENERATED BY DEFAULT AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1 ),
    companyname character varying(100) COLLATE pg_catalog."default" NOT NULL,
    payamount double precision,
    paymentdate timestamp without time zone,
    paymentmode character varying(50) COLLATE pg_catalog."default",
    createddate timestamp without time zone,
    orderid bigint,
    CONSTRAINT tbl_vendor_payment_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.tbl_vendor_payment
    OWNER to postgres;
-------------------tbl_vendor_payment_history
-- Table: public.tbl_vendor_payment_history

-- DROP TABLE IF EXISTS public.tbl_vendor_payment_history;

CREATE TABLE IF NOT EXISTS public.tbl_vendor_payment_history
(
    id bigint NOT NULL GENERATED BY DEFAULT AS IDENTITY ( INCREMENT 1 START 1 MINVALUE 1 MAXVALUE 9223372036854775807 CACHE 1 ),
    companyname character varying(100) COLLATE pg_catalog."default" NOT NULL,
    payamount double precision,
    paymentdate timestamp without time zone,
    paymentmode character varying(50) COLLATE pg_catalog."default",
    createddate timestamp without time zone,
    orderid bigint,
    paymentid bigint,
    CONSTRAINT tbl_vendor_payment_history_pkey PRIMARY KEY (id)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.tbl_vendor_payment_history
    OWNER to postgres;

-- create function voucher 16-11-2023
CREATE OR REPLACE FUNCTION get_voucher_info(
    p_company_type VARCHAR,
    p_voucher_no BIGINT DEFAULT NULL
) RETURNS TABLE (
    voucher_no BIGINT
) AS $$
BEGIN
    IF p_voucher_no IS NULL THEN
        -- Only companyType is provided, return the max voucher number
        RETURN QUERY
        SELECT s.voucherno
        FROM tbl_salesordercompany s
        JOIN company c ON s.companyname = c.companyname
        WHERE c.companytype = p_company_type
        ORDER BY s.voucherno DESC
        LIMIT 1;
    ELSE
        -- Both companyType and voucherNo are provided, check if voucherNo exists
        RETURN QUERY
        SELECT CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END
        FROM tbl_salesordercompany s
        JOIN company c ON s.companyname = c.companyname
        WHERE c.companytype = p_company_type AND s.voucherno = p_voucher_no;
    END IF;
END;
$$ LANGUAGE plpgsql;


-- Table: public.tbl_expense

-- DROP TABLE IF EXISTS public.tbl_expense;  15-01-2024

CREATE TABLE IF NOT EXISTS public.tbl_expense
(
    expenseid bigint NOT NULL,
    expensecategoryid bigint NOT NULL,
    companyid bigint NOT NULL,
    expensedate time without time zone,
    amount double precision NOT NULL,
    description character varying COLLATE pg_catalog."default",
    paymentmethod character varying COLLATE pg_catalog."default",
    createddate timestamp without time zone,
    CONSTRAINT tbl_expense_pkey PRIMARY KEY (expenseid)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.tbl_expense
    OWNER to postgres;


    -- Table: public.tbl_expense_category

-- DROP TABLE IF EXISTS public.tbl_expense_category; 15-01-2024

CREATE TABLE IF NOT EXISTS public.tbl_expense_category
(
    categoryid bigint NOT NULL,
    companyid bigint,
    categoryname character varying COLLATE pg_catalog."default" NOT NULL,
    description character varying COLLATE pg_catalog."default",
    createddate timestamp without time zone,
    CONSTRAINT tbl_expense_category_pkey PRIMARY KEY (categoryid)
)

TABLESPACE pg_default;

ALTER TABLE IF EXISTS public.tbl_expense_category
    OWNER to postgres;