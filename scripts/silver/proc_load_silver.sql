/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs ETL (Extract, transform and load) data into the 'silver' schema from the 'bronze' schema. 
    It performs the following actions:
    - Truncates the Silver tables before loading data.
    - Transforms and cleanses the data before inserting it into the Silver tables.
    - Applies business rules such as deduplication, categorization, and validation.

Parameters:
    None.
    This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC silver.load_silver;
===============================================================================
*/


CREATE OR ALTER PROCEDURE [silver].[load_silver] AS 

BEGIN

    DECLARE @batch_start_time DATETIME2, @batch_end_time DATETIME2, @start_time DATETIME2, @end_time DATETIME2;
    SET @batch_start_time = GETDATE();

    BEGIN TRY

        PRINT '========================================';
        PRINT 'Loading Silver Layer';
        PRINT '========================================';

        PRINT '----------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '----------------------------------------';

        SET @start_time = GETDATE();

        PRINT ' >> Truncating Table: silver.crm_cust_info';
        TRUNCATE TABLE silver.crm_cust_info
        PRINT '>> Inserting Data Into: silver.crm_cust_info';

        INSERT INTO silver.crm_cust_info(
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gndr,
            cst_create_date
        )


        SELECT 
            cst_id,
            cst_key,
            TRIM(cst_firstname) AS cst_firstname,
            TRIM(cst_lastname) AS cst_lastname,
            CASE  WHEN upper(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                WHEN upper(TRIM(cst_marital_status)) = 'S' THEN 'Single'
                ELSE 'n/a'
            END cst_marital_status,
            CASE  WHEN upper(TRIM(cst_gndr)) = 'M' THEN 'Male'
                WHEN upper(TRIM(cst_gndr)) = 'F' THEN 'Female'
                ELSE 'n/a'
            END  cst_gndr,
            cst_create_date
        FROM 

        (
            SELECT 
                *,
                ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
            FROM 
                bronze.crm_cust_info 
            WHERE 
                cst_id IS NOT NULL
        ) t 

        WHERE 
            flag_last = 1;

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + 'seconds';
        PRINT ' ------------------------------------'


        SET @start_time = GETDATE();
        PRINT ' >> Truncating Table: silver.crm_prd_info';
        TRUNCATE TABLE silver.crm_prd_info
        PRINT '>> Inserting Data Into: silver.crm_prd_info';

        INSERT INTO silver.crm_prd_info(

            prd_id,
            cat_id,
            prd_key,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_dt

        )


        SELECT  prd_id  
            , REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id  
            , SUBSTRING(prd_key, 7,len(prd_key)) AS prd_key
            , prd_nm  
            , ISNULL(prd_cost, 0) AS prd_cost  
            , CASE upper(trim(prd_line))
                    WHEN 'M' THEN 'Mountain'
                    WHEN 'R' THEN 'Road'
                    WHEN 'S' THEN 'Other Sales'
                    WHEN 'T' THEN 'Touring'
                    ELSE 'n/a'
                END AS prd_line 
            ,CAST([prd_start_dt] AS DATE) AS prd_start_dt
            ,CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE) AS prd_end_dt_test 
        FROM bronze.crm_prd_info;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + 'seconds';
        PRINT ' ------------------------------------'


        SET @start_time = GETDATE();
        PRINT ' >> Truncating Table: silver.crm_sales_details';
        TRUNCATE TABLE silver.crm_sales_details
        PRINT '>> Inserting Data Into: silver.crm_sales_details';
        INSERT INTO silver.crm_sales_details (

            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_quantity,
            sls_price
        )


        SELECT  
            [sls_ord_num],
            [sls_prd_key],
            [sls_cust_id],
            CASE
                WHEN sls_order_dt = 0 or len(sls_order_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_order_dt AS varchar) AS date)
            END AS sls_order_dt,

            CASE 
                WHEN sls_ship_dt = 0 or len(sls_ship_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_ship_dt AS varchar) AS date)
            END AS sls_ship_dt,

            CASE  WHEN sls_due_dt = 0 or len(sls_due_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_due_dt AS varchar) AS date)
            END AS sls_due_dt,
            
            CASE
                WHEN sls_sales != (sls_quantity * ABS(sls_price)) or sls_sales <= 0 or sls_sales IS NULL
            THEN sls_quantity * ABS(sls_price)
            ELSE sls_sales
            END AS sls_sales,

            [sls_quantity],

            CASE
                WHEN sls_price <=0 or sls_price IS NULL 
            THEN  ABS(sls_sales)/nullif(sls_quantity, 0) 
            ELSE sls_price
            END AS  sls_price

        FROM [DataWarehouse].[bronze].[crm_sales_details] ;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + 'seconds';
        PRINT ' ------------------------------------'


        PRINT '----------------------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '----------------------------------------';

        SET @start_time = GETDATE();
        PRINT ' >> Truncating Table: silver.erp_cust_az12';
        TRUNCATE TABLE silver.erp_cust_az12
        PRINT '>> Inserting Data Into: silver.erp_cust_az12';
        INSERT INTO silver.erp_cust_az12(
            cid,
            bdate,
            gen
        )

        SELECT 

            CASE 
                WHEN cid like'%NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
                ELSE cid
            END AS cid,

            CASE 
                WHEN bdate > GETDATE() THEN NULL
                ELSE bdate
            END AS bdate,

            CASE 
                WHEN UPPER(left(gen,LEN(trim(gen))-1)) in ('F', 'FEMALE') THEN 'Female'
                WHEN UPPER(left(gen, len(TRIM(gen))-1)) in ('M', 'MALE') THEN 'Male'
                ELSE 'n/a'
            END AS gen 
            
        FROM [DataWarehouse].[bronze].[erp_cust_az12];
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + 'seconds';
        PRINT ' ------------------------------------'

        SET @start_time = GETDATE();
        PRINT ' >> Truncating Table: silver.erp_loc_a101';
        TRUNCATE TABLE silver.erp_loc_a101
        PRINT '>> Inserting Data Into: silver.erp_loc_a101';
        INSERT INTO silver.erp_loc_a101(
            cid,
            cntry
        )

        SELECT 
            REPLACE(cid, '-','') AS cid,
            case
                WHEN left(cntry, len(trim(cntry))-1) = ' ' or left(cntry, len(trim(cntry))-1) IS NULL  THEN 'n/a'
                WHEN left(cntry, len(trim(cntry))-1) in ('US', 'USA') THEN 'United States'
                WHEN  left(cntry, len(trim(cntry))-1) = 'DE' THEN 'Germany'
                ELSE  left(cntry, len(trim(cntry))-1)
            END AS cntry from bronze.erp_loc_a101;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + 'seconds';
        PRINT ' ------------------------------------'


        SET @start_time = GETDATE();
        PRINT ' >> Truncating Table: silver.erp_px_cat_g1v2';
        TRUNCATE TABLE silver.erp_px_cat_g1v2
        PRINT '>> Inserting Data Into: silver.erp_px_cat_g1v2';
        INSERT INTO silver.erp_px_cat_g1v2(
            id,
            cat,
            subcat,
            maintenance)

        SELECT id AS id
            ,cat
            ,subcat
            ,CASE 
                WHEN maintenance in ('No', 'Yes') THEN TRIM(maintenance)
                ELSE left(maintenance,len(TRIM(maintenance))-1)
            END AS maintenance
            
        FROM [DataWarehouse].[bronze].[erp_px_cat_g1v2];
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + 'seconds';
        PRINT ' ------------------------------------'

        
    SET @batch_end_time = GETDATE();
    PRINT '========================================';
    PRINT 'Loading Silver Layer is completed';
    PRINT ' >>  Total Silver Layer Load Duration:' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS VARCHAR) + 'seconds';
    PRINT '========================================';

    END TRY

    BEGIN CATCH

        PRINT('================================================');
        PRINT('ERROR OCCURED DURING LOADING THE SILVER LAYER');
        PRINT('ERROR MESSAGE'+ ERROR_MESSAGE());
        PRINT('ERROR NUMBER' + CAST(ERROR_NUMBER() AS NVARCHAR));
        PRINT('ERROR STATE' + CAST(ERROR_STATE() AS NVARCHAR));
        PRINT('================================================');

    END CATCH

END

