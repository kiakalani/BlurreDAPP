import datetime
import base64
import io


from flask import jsonify, current_app
from flask_login import current_user
from sqlalchemy import Column, DateTime, String, Integer, or_, and_

import blueprints.abstracts as abstracts


class MessageTable(current_app.config['DB']['base']):
    """
    The message table for SQL ORM
    """

    __tablename__ = 'message'
    id = Column(Integer, primary_key=True)
    timestamp = Column(DateTime)
    sender = Column(Integer)
    receiver = Column(Integer)
    message = Column(String)
    def __init__(self, sender: int, receiver: int, message: str) -> None:
        self.timestamp = datetime.datetime.now()
        self.sender = sender
        self.receiver = receiver
        self.message = message

    

class Message(abstracts.BP):
    """
    The message blueprint. This class would be
    responsible for handling all the messaging
    functionality.
    """

    def __init__(self) -> None:
        super().__init__('message')

    @staticmethod
    def bp_post() -> list:
        def receive_message():
            return jsonify({'Todo': '''
                Implement messaging backend
            '''})
        def send_message(a0):
            return jsonify({'Todo': '''
            Implement messaging to a recepient functionality.
            Integrate Socket with this.
            '''})
        return [receive_message, send_message]
