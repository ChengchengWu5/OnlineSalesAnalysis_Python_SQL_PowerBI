/*
==========================================================================
Stored Procedure: Set up start schema constraints
--------------------------------------------------------------------------
Script Purpose:
	This script sets up start schema constraints by:
    - setting key columns as NOT NULL
    - adding primary and/or foreign key constraints to the fact_orders, 
      dim_customers, and dim_products.

Usage Example:
    EXEC dbo.usp_setup_star_schema_constraints;
==========================================================================
*/

USE OnlineSales;
GO

IF OBJECT_ID(N'dbo.usp_setup_star_schema_constraints', N'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_setup_star_schema_constraints;
GO

CREATE PROCEDURE dbo.usp_setup_star_schema_constraints AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Alter columns to NOT NULL
        ALTER TABLE fact_orders
            ALTER COLUMN orders_key INT NOT NULL;

        ALTER TABLE fact_orders
            ALTER COLUMN customer_key INT NOT NULL;

        ALTER TABLE fact_orders
            ALTER COLUMN product_key INT NOT NULL;

        ALTER TABLE dim_customers
            ALTER COLUMN customer_key INT NOT NULL;

        ALTER TABLE dim_products
            ALTER COLUMN product_key INT NOT NULL;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;

    -- Add primary keys with checks
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE name = 'PK_fact_orders')
            ALTER TABLE fact_orders
                ADD CONSTRAINT PK_fact_orders PRIMARY KEY (orders_key);

        IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE name = 'PK_dim_customers')
            ALTER TABLE dim_customers
                ADD CONSTRAINT PK_dim_customers PRIMARY KEY (customer_key);

        IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE name = 'PK_dim_products')
            ALTER TABLE dim_products
                ADD CONSTRAINT PK_dim_products PRIMARY KEY (product_key);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;

    -- Add foreign keys with checks
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_orders_customers')
            ALTER TABLE fact_orders
                ADD CONSTRAINT FK_orders_customers FOREIGN KEY (customer_key) REFERENCES dim_customers(customer_key);

        IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_orders_products')
            ALTER TABLE fact_orders
                ADD CONSTRAINT FK_orders_products FOREIGN KEY (product_key) REFERENCES dim_products(product_key);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO
