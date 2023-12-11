# -*- coding: utf8 -*-
import re
import json
from os import getenv
import pymysql
from pymysql.err import OperationalError

mysql_conn = None

# function to parse path string from json event inputed
# path contains information about step to execute
def __get_Path(path):
    pattern = r'^/(\w+)/(\w+)/(\w+)$'
    try:
        match = re.match(pattern, path)
        print("[+] Path found or defined", match.group(1))
        return (match.group(2), match.group(3))
    except Exception as e:
        print("[-] Path not found or defined e.g. /chainlink/P001/stats")
        raise e
        

# function to create mysql cursor to database
def __get_cursor():
    try:
        return mysql_conn.cursor()
    except OperationalError:
        mysql_conn.ping(reconnect=True)
        return mysql_conn.cursor()

def __get_patient_info(pid):
    global mysql_conn
    if not mysql_conn:
        mysql_conn = pymysql.connect(
            host=getenv('DB_HOST'),
            user=getenv('DB_USER'),
            password=getenv('DB_PASSWORD'),
            db=getenv('DB_DATABASE'),
            port=int(getenv('DB_PORT')),
            charset='utf8mb4',
            cursorclass=pymysql.cursors.DictCursor
        )
    
    with __get_cursor() as cursor:
        sql = "select directory_sample from patientdata where patient_id = %s;"
        cursor.execute(sql, (pid))
        res = cursor.fetchall()
        return res

def __get_stats(pid):
    global mysql_conn
    if not mysql_conn:
        mysql_conn = pymysql.connect(
            host=getenv('DB_HOST'),
            user=getenv('DB_USER'),
            password=getenv('DB_PASSWORD'),
            db=getenv('DB_DATABASE'),
            port=int(getenv('DB_PORT')),
            charset='utf8mb4',
            cursorclass=pymysql.cursors.DictCursor
        )
    
    with __get_cursor() as cursor:
        sql = "SELECT u.steps_walked,u.bmi,u.calories,s.temperature,s.airquality,s.uvexposure,s.humidity FROM userdataiot u JOIN smartcity s ON u.city = s.city WHERE u.patient_id = %s ;"
        cursor.execute(sql, (pid))
        res = cursor.fetchall()
        return res

def main_handler(event, response):
    pid,job =  __get_Path(event['path'])
    if job == "record":
        value = __get_patient_info(pid)
    elif job == "stats":
        value = __get_stats(pid)
    return value
