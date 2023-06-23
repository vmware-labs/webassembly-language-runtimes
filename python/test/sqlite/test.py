import traceback

import sqlite3
import sys

DB_FILE_NAME = 'test.db'

def create_table(con, name, schema):
    cursorObj = con.cursor()
    cursorObj.execute(f"CREATE TABLE {name}{schema}")
    con.commit()

def populate_table(con, name):
    cursorObj = con.cursor()
    cursorObj.execute(f"INSERT INTO {name} VALUES(1, 'John', 700, 'TheDarkMaster')")
    cursorObj.execute(f"INSERT INTO {name} VALUES(2, 'Jane', 710, 'AngelOfBenevolence')")
    cursorObj.execute(f"INSERT INTO {name} VALUES(3, 'George', 623, 'MagiFromTheDeep')")
    con.commit()

def select_table(con, name):
    cursorObj = con.cursor()
    cursorObj.execute(f"SELECT * FROM {name}")
    rows = cursorObj.fetchall()
    for row in rows:
        print(row)

def sql_version(con):
    cursor = con.cursor()

    sqlite_select_Query = "select sqlite_version();"
    cursor.execute(sqlite_select_Query)
    record = cursor.fetchall()
    print("SQLite Database Version is: ", record)
    cursor.close()

connection = None
try:
    connection = sqlite3.connect(DB_FILE_NAME)
    print("Database created and Successfully Connected to SQLite")

    sql_version(connection)

    try:
        create_table(connection, "players", "(id integer PRIMARY KEY, name text, score real, nickname text)")
    except sqlite3.Error as e:
        print("Error while trying to create table: ", e)

    try:
        populate_table(connection, "players")
    except sqlite3.Error as e:
        print("Error while trying to create table: ", e)


    try:
        select_table(connection, "players")

    except sqlite3.Error as e:
        print("Error while trying to fetch table: ", e)


except sqlite3.Error as error:
    print("Error while connecting to sqlite", error)

    print(traceback.format_exc())

finally:
    if connection:
        connection.close()
        print("The SQLite connection is closed")
    import os
    if os.path.isfile(DB_FILE_NAME):
        os.remove(DB_FILE_NAME)
        print(f"File '{DB_FILE_NAME}' deleted!")

