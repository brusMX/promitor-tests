import os
import sys
import string
import psycopg2

class PGConnection:
    def parse_file(self, item):
        response = ''
        path_to_file = f'{self.path_to_creds}/{item}-p.txt'
        if not os.path.isfile(path_to_file):
            print(f"Error: Could not find {item} mounted in \'{path_to_file}\''")
            sys.exit(1)
        with open(path_to_file) as f:
            response = f.readline().strip()
        if not response:
            print(f"Error: Could not find {item} mounted in \'{path_to_file}\''")
            sys.exit(1)
        return response

    def obtain_credentials(self):
        print("Obtaining credentials...")
        self.hostname = self.parse_file('hostname')
        self.username = self.parse_file('username')
        self.password = self.parse_file('password')
        print("Obtained.")

    def try_to_connect(self):
        print("Trying to connect to database...")
        try:
            connection = psycopg2.connect(user = self.username,
                                  password = self.password,
                                  host = self.hostname,
                                  port = "5432",
                                  database = self.table)
            print ( connection.get_dsn_parameters(),"\n")
        except (Exception, psycopg2.Error) as error :
            print ("Error while connecting to PostgreSQL", error)
            sys.exit(1)
        print("Connected.")
        return connection

    def close_connection(self):
        if(self.connection):
            if (self.cursor):
                self.cursor.close()
            self.connection.close()
            print("PostgreSQL connection is closed")
            
    def __init__(self):
        self.path_to_creds = '/usr/src/app/postgresql-con'
        self.table    = 'sampletable'
        self.obtain_credentials()
        self.connection = self.try_to_connect()
        self.cursor = self.connection.cursor()





