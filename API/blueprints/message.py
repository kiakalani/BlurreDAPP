import datetime
import base64
import io


from flask import jsonify, current_app
from flask_login import current_user
from sqlalchemy import Column, DateTime, String, Integer, or_, and_, Boolean

import blueprints.abstracts as abstracts
import blueprints.matches as match
import blueprints.auth as auth

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
    read = Column(Boolean)
    def __init__(self, sender: int, receiver: int, message: str) -> None:
        self.timestamp = datetime.datetime.now()
        self.sender = sender
        self.receiver = receiver
        self.message = message
        self.read = False

def get_message_recepients():
    """
    This method returns the matched users name and id in the
    following format:
    {id(int): {name: str, new_messages: int}}
    """
    if current_user.is_anonymous:
        return {}
    matches = match.get_matches()
    matches = {i: {} for i in matches}
    for i in matches:
        user = auth.User.query.filter(user.id == i).first()
        if not user:
            del matches[i]
        else:
            matches[i]['name'] = user.name
            matches[i]['new_messages'] = len(MessageTable.query.filter(
                and_(
                    MessageTable.sender == i,
                    MessageTable.receiver == current_user.id
                )
            ).all())
    return matches

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
            if current_user.is_anonymous:
                return Message.create_response(jsonify({
                    'message': 'Unauthorized'
                })), 400
            # Provide the messages
            return jsonify({
                'message': 'success',
                'info': get_message_recepients()
            })
        def send_message(a0):
            return jsonify({'Todo': '''
            Implement messaging to a recepient functionality.
            Integrate Socket with this.
            '''})
        return [receive_message, send_message]
