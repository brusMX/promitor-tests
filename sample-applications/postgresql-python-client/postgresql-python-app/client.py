from classes.pgconnection import PGConnection
from classes.individual import Individual
from faker import Faker
import random 




def create_individuals(amount=15):
    response = []
    fake = Faker()
    for i in range(0, amount):
        response.append(Individual(fake.name, fake.address, random.randint(1,75), random.uniform(1,2.2)))
    return response
        
if __name__ == "__main__":
    pg = PGConnection()
    print (create_individuals())
    print ("done with class")
    pg.close_connection()