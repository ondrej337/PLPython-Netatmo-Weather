# Postgres PLPython-Netatmo-Weather
Download data from Netatmo weather module/station to Postgress DB using PLPython

## 1. Instal Python Netatmo-Weather
   https://github.com/philippelt/netatmo-api-python (follow the instruction)

     pip install lnetatmo

        
## 2. Create Schema netatmo_weather, mycron

    CREATE SCHEMA daikin;
    
    CREATE SCHEMA mycron;

## 2.1 Create 4 tables on schema netatmo_weather:

 download file: netatmo_weather.sql

## 2.2 Create function mycron.py_netatmo()

 download file: mycron_py_netatmo.sql
  
## 2.3 Call function:

 Call plpython function to copy data to dB: (testing)

    SELECT mycron.py_netatmo();
  

## 3. PGcron job:
    
   Create JOB: (every 5 minutes)

    SELECT cron.schedule ('Netatmo_Weather','*/5 * * * *',$$select mycron.py_netatmo()$$);

   Unselect from cron: 17->id_job:

    select cron.unschedule(17); 
    
   Table of the created jobs:    

    SELECT * FROM cron.job;
    
   History of jobs run:  

    select * from cron.job_run_details order by runid desc;
