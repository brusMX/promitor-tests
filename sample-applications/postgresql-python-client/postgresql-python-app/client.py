from classes.pgconnection import PGConnection
from classes.individual import Individual
from faker import Faker
import random 
import time 
import sys



def create_some_individuals(pg):
    if pg.connection:
        individuals = []
        fake = Faker()
        for i in range(0, random.randint(150,400)):
            aux = Individual(fake.name(), fake.address(), random.randint(1,75), round(random.uniform(1,2.2),2))
            individuals.append(aux)
        pg.insert_individuals(individuals)


def delete_some_individuals(pg):
    if pg.connection:
        num1 = random.randint(1,50)
        num2 = random.randint(20,75)
        if (num1 > num2):
            aux = num1
            num1 = num2
            num2 = aux
        pg.delete_individuals_by_age(num1, num2)



if __name__ == "__main__":
    interval = 300
    pg = PGConnection()
    while True:
        case = random.randint(1,2)
        pg.try_to_connect()
        if case == 1:
            create_some_individuals(pg)
        else:
            delete_some_individuals(pg)
        rows = pg.rows_in_individual_table()
        pg.close_connection()
        print(f"{rows} rows. Sleeping for {interval} seconds...\n")
        sys.stdout.flush()
        time.sleep(2)
            

    