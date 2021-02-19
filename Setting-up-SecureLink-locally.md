### The SecureLink repo expects Postgres version 12 or later. (It users the Generated Columns feature.) We can tweak some column definitions to make the SQL work on an earlier version of Postgres. Here is how jccraft got things working locally.

1. Create the 'securelink' database.

2. Tweak some SQL statements to accommodate PostgreSQL version < 12.  
file: migrations/versions/3a331d9ea555_.py:  
Replace the first two lines in def upgrade() with:  
`op.add_column('lis_record', sa.Column('identifiers', sa.ARRAY(sa.String())))  `  
`op.add_column('lis_record', sa.Column('nameindex', sqlalchemy_utils.types.ts_vector.TSVectorType()))`  <P>
file: migrations/versions/f3989aef2bc0_.py:  
Replace the line that adds the 'searchall' column with:  
`op.add_column('lis_record', sa.Column('searchall', sa.String()))`

3. Run the migrations to create the database objects.  
PGHOST=localhost PGDATABASE=securelink PGUSER={your user} PGPASSWORD={your database} FLASK_ENV=development flask db upgrade

4. Insert a row of result data for SCAN. For example:  
`INSERT INTO qr_code_result_scan (barcode, dob, result, qrcode_ok) values ('CCCCCCCC' , '2020-01-01',   `
`'{"pat_num": "U1111111", "pat_name": "John Doe", "birth_date": "2020-01-01", "collect_ts": "2020-03-14 08:43:00", "qrcode": "CCCCCCCC", "status_code": "negative", "pre_analytical_specimen_collection": "IRB"}  `
`', true)  `

5. Update the row as needed:  
`update qr_code_result_scan   `
`set result =   `
`'{"pat_num": "U1111111", "pat_name": "John Doe", "birth_date": "2020-01-01", "collect_ts": "2020-03-14 08:43:00", "qrcode": "CCCCCCCC", "status_code": "negative", "pre_analytical_specimen_collection": "Clinical"}  `
`'  `
`WHERE barcode = 'CCCCCCCC'`

5. Update the dev configuration in /app/config.py to include your user and password:  
class DevelopmentConfig(Config):  
SQLALCHEMY_DATABASE_URI = "postgres://{user}:{password}@localhost/securelink"

5. Run the server  
FLASK_ENV=development python3 run.py

6. Access the site under /scan:  
http://127.0.0.1:5000/scan