import duckdb

sql_import_hr_staff_current = """
create or replace table hr_staff_current as
select * 
from read_csv_auto(
        'source_data/HR Staff current data.csv',
        normalize_names=True,
        nullstr='#N/A'
        )
"""

sql_import_hr_staff_mobility = """
create or replace table hr_staff_mobility as
select * 
from read_csv_auto(
        'source_data/HR Staff Mobility Analytics.csv',
        normalize_names=True,
        nullstr='#N/A'
        )
"""

sql_import_db_staff = """
create or replace table db_staff as
select * 
from read_csv_auto(
        'source_data/db-staff.csv',
        normalize_names=True,
        types={
            'styles': 'VARCHAR[]',
            'industries': 'VARCHAR[]',
            'software': 'VARCHAR[]',
            }
        )
"""

with duckdb.connect('data/superside_hr_data.db') as con:
    con.sql(sql_import_hr_staff_current)
    con.sql(sql_import_hr_staff_mobility)
    con.sql(sql_import_db_staff)
