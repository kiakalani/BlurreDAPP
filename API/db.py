import os

from sqlalchemy import create_engine, Engine
from sqlalchemy.orm import scoped_session, sessionmaker, declarative_base

def init_db(env_name='DBPATH') -> dict:
    """
    Returns the dictionary containing the
    needed variables of SQLAlchemy database.
    :param:env_name: refers to the environment
    variable for the path of the database.
    :return: The dictionary containing the database
    instances.
    """
    path = os.environ.get(env_name)
    if not path:
        print('Error connecting to database. Invalid path provided')
        return {}
    