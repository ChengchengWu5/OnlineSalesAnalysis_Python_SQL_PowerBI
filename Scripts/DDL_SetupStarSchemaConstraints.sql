/*
==========================================================================
Stored Procedure: Set up start schema constraints
--------------------------------------------------------------------------
Script Purpose:
	This script sets up start schema constraints by:
    - setting key columns as NOT NULL
    - adding primary and/or foreign key constraints to the fact_orders, 
      dim_customer, dim_product, and dim_date tables.

Usage Example:
    EXEC dbo.usp_SetupStarSchemaConstraints;
==========================================================================
*/

USE OnlineSales;
GO

IF OBJECT_ID(N'dbo.usp_SetupStarSchemaConstraints', N'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_SetupStarSchemaConstraints;
GO

CREATE PROCEDURE dbo.usp_SetupStarSchemaConstraints AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Alter columns to NOT NULL
        ALTER TABLE fact_orders
            ALTER COLUMN OrdersKey INT NOT NULL;

        ALTER TABLE fact_orders
            ALTER COLUMN CustomerKey INT NOT NULL;

        ALTER TABLE fact_orders
            ALTER COLUMN ProductKey INT NOT NULL;

        ALTER TABLE fact_orders
            ALTER COLUMN DateKey INT NOT NULL;

        ALTER TABLE dim_customer
            ALTER COLUMN CustomerKey INT NOT NULL;

        ALTER TABLE dim_product
            ALTER COLUMN ProductKey INT NOT NULL;

        ALTER TABLE dim_date
            ALTER COLUMN DateKey INT NOT NULL;

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

        IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE name = 'PK_orders_fact')
            ALTER TABLE fact_orders
                ADD CONSTRAINT PK_orders_fact PRIMARY KEY (OrdersKey);

        IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE name = 'PK_dim_customer')
            ALTER TABLE dim_customer
                ADD CONSTRAINT PK_dim_customer PRIMARY KEY (CustomerKey);

        IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE name = 'PK_dim_product')
            ALTER TABLE dim_product
                ADD CONSTRAINT PK_dim_product PRIMARY KEY (ProductKey);

        IF NOT EXISTS (SELECT * FROM sys.key_constraints WHERE name = 'PK_dim_date')
            ALTER TABLE dim_date
                ADD CONSTRAINT PK_dim_date PRIMARY KEY (DateKey);

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

        IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_orders_customer')
            ALTER TABLE fact_orders
                ADD CONSTRAINT FK_orders_customer FOREIGN KEY (CustomerKey) REFERENCES dim_customer(CustomerKey);

        IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_orders_product')
            ALTER TABLE fact_orders
                ADD CONSTRAINT FK_orders_product FOREIGN KEY (ProductKey) REFERENCES dim_product(ProductKey);

        IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_orders_date')
            ALTER TABLE fact_orders
                ADD CONSTRAINT FK_orders_date FOREIGN KEY (DateKey) REFERENCES dim_date(DateKey);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO
