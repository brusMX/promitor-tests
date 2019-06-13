import os
import sys
import string
import psycopg2
from classes.individual import Individual


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
    def insert_individual(self, individual):
        response = False
        if (type(individual) == Individual):
            postgres_insert_query = f" INSERT INTO INDIVIDUAL (NAME, ADDRESS, AGE, HEIGHT) VALUES ('{individual.name}','{individual.address}','{individual.age}','{individual.height}')"
            self.cursor.execute(postgres_insert_query)
            self.connection.commit()
            count = self.cursor.rowcount
            if (count>0) :
                response = True
        return response

    def insert_individuals(self, individuals):
        count = 0
        for individual in individuals:
             if (not self.insert_individual(individual)):
                 count += 1
        if not count :
            print(f"Inserted {len(individuals)} individuals")
        else:
            print(f"{count} records were not inserted")


    def obtain_credentials(self):
        self.hostname = self.parse_file('hostname')
        self.username = self.parse_file('username')
        self.password = self.parse_file('password')
        print("Obtained credentials .")

    def create_individual_table(self):
        create_query='CREATE TABLE IF NOT EXISTS INDIVIDUAL (_id SERIAL PRIMARY KEY, NAME VARCHAR(255) NOT NULL, ADDRESS VARCHAR(255), AGE INTEGER NOT NULL, HEIGHT DECIMAL);'
        self.cursor.execute(create_query)
        self.connection.commit()
        
    def delete_individuals_by_age(self, min_age, max_age):
        delete_query=f'DELETE FROM INDIVIDUAL WHERE INDIVIDUAL.AGE < {max_age} and INDIVIDUAL.AGE > {min_age};'
        self.cursor.execute(delete_query)
        self.connection.commit()
        print(f"{self.cursor.rowcount} individuals deleted")

        

    def try_to_connect(self):
        try:
            connection = psycopg2.connect(user = self.username,
                                  password = self.password,
                                  host = self.hostname,
                                  port = "5432",
                                  database = self.table)
        except (Exception, psycopg2.Error) as error :
            print ("Error while connecting to PostgreSQL", error)
        self.connection = connection
        self.cursor = self.connection.cursor()


    def rows_in_individual_table(self):
        response = None
        if(self.connection):
            count_query = "SELECT COUNT(*) FROM INDIVIDUAL;"
            self.cursor.execute(count_query)
            result = self.cursor.fetchone()[0]
            response = result
        return response
        

    def close_connection(self):
        if(self.connection):
            if (self.cursor):
                self.cursor.close()
            self.connection.close()
    
            
    def __init__(self):
        self.path_to_creds = '/tmp/postgresql-con'
        self.table    = 'postgres'
        self.obtain_credentials()
        self.try_to_connect()
        self.create_individual_table()





