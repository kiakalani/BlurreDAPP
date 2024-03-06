import os
from typing import TypedDict

from flask import Flask, current_app
from sqlalchemy import create_engine, Engine
from sqlalchemy.orm import scoped_session, sessionmaker, declarative_base, DeclarativeBase, Session

class DBComps(TypedDict):
    """
    The database dictionary with the
    required components.
    """
    engine: Engine
    session: Session
    base: DeclarativeBase
    destroy: any

def init_db(env_name='SQLDB') -> DBComps:
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
        return {
            'engine': None,
            'session': None,
            'base': None
        }
    
    # Creating the needed variables for the database
    engine = create_engine(f'sqlite:///{path}')
    session = scoped_session(sessionmaker(autoflush=False, bind=engine))
    base = declarative_base()
    base.query = session.query_property()

    return {
        'engine': engine,
        'session': session,
        'base': base,
        'destroy': lambda : session.remove()
    }


def load_orms(app: Flask) -> None:
    """
    Adding all of the orms to the database.
    :param: app: The flask application
    :return: None
    """
    from auth import User
    from profile_imp import Profile
    from message import MessageTable
    from matches import MatchTable
    db_inf: DBComps = app.config['DB']
    db_inf['base'].metadata.create_all(bind=db_inf['engine'])

def get_db() -> DBComps:
    """
    Getter for components of the database.
    :return: The components of the database.
    """
    return current_app.config['DB']
