import os
import sys
import string
import asyncio
import asyncpg

pathToUserFile ='/usr/src/app/postgresql-con/username-p.txt'
pathToPassFile ='/usr/src/app/postgresql-con/password-p.txt'
pathToHostnameFile ='/usr/src/app/postgresql-con/hostname-p.txt'


pgUser = ''
pgPass = ''
pgHostname = ''


getPgConnectionString()

def getPgConnectionString():
    resultingConnectionString = ''

    pgUserExists = os.path.isfile(pathToUserFile)
    pgPassExists = os.path.isfile(pathToPassFile)
    pgHostnameExists = os.path.isfile(pathToHostnameFile)

    if not pgUserExists or not pgPassExists :
        # Store configuration file values
        print("Error: Could not find hostname/username/password for PostgreSQL")
        sys.exit(1)

    with open(pathToUserFile) as f:
        pgUser = f.readline().strip()
    with open(pathToPassFile) as f:
        pgPass = f.readline().strip()
    with open(pathToUserFile) as f:
        pgUser = f.readline().strip()
    with open(pathToHostnameFile) as f:
        pgHostname = f.readline().strip()

    if not pgUser or not pgPass :
        # Store configuration file values
        print("Error: Username or Password is empty")
        sys.exit(1)


    resultingConnectionString = f"postgresql://{pgUser}:{pgPass}@{pgHostname}/sampletable"