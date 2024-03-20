import datetime
import base64
import io
import calendar


from flask import jsonify, current_app, request
from flask_login import current_user
from sqlalchemy import Column, DateTime, String, Integer, or_, and_, Boolean

import blueprints.abstracts as abstracts
import blueprints.matches as match
import blueprints.auth as auth
import blueprints.profile_imp as prof


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
    {id(int): {name: str, new_messages: int, picture: str}}
    """
    if current_user.is_anonymous:
        return {}
    matches = match.get_matches()
    matches = {i: {} for i in matches}
    for i in matches:
        user = auth.User.query.filter(auth.User.id == i).first()
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
            matches[i]['picture'] = prof.get_recepient_images(
                user.id,
                prof.Profile.query.filter(prof.Profile.email == user.email).first()
            )['picture1']
    return matches

def get_updated_pic(user, user2) -> str:
    """
    Provides the first picture of the given user after
    each message.
    :param: user: The user we are trying to get its image.
    :param: user2: the current user.
    """
    if (prof.get_blur_level(user.id, user2.id) == 0):
        return None
    return prof.get_image(user, user2)

class Message(abstracts.BP):
    """
    The message blueprint. This class would be
    responsible for handling all the messaging
    functionality.
    """

    def __init__(self) -> None:
        super().__init__('message')
    @staticmethod
    def bp_get() -> list:
        def get_related_msgs(a0):
            if current_user.is_anonymous:
                return Message.create_response(jsonify({
                    'message': 'Unauthorized'
                })), 400
            if not a0.isdigit():
                return Message.create_response(jsonify({
                    'message': 'Bad request'
                })), 400
            uid = int(a0)
            user = auth.User.query.filter(auth.User.id == uid).first()
            if not user:
                return Message.create_response(jsonify({
                    'message': 'Bad request'
                })), 400
            messages = MessageTable.query.filter(
                or_(
                    and_(
                        MessageTable.sender == uid,
                        MessageTable.receiver == current_user.id
                    ),
                    and_(
                        MessageTable.sender == current_user.id,
                        MessageTable.receiver == uid
                    )
                )
            ).all()
            messages = [{key.name: getattr(m, key.name) for key in MessageTable.__table__.columns} for m in messages]
            for m in messages:
                datetime.datetime.now().timestamp()
                m['timestamp'] = int(m['timestamp'].timestamp())
            return jsonify(
                {
                    'message': 'success',
                    'messages': messages
                }
            )
        return [get_related_msgs]

    @staticmethod
    def bp_post() -> list:
        def receive_message():
            if current_user.is_anonymous:
                return Message.create_response(jsonify({
                    'message': 'Unauthorized'
                })), 400
            # Provide the messages
            return Message.create_response(jsonify({
                'message': 'success',
                'info': get_message_recepients()
            }))
        def send_message(a0):
            """
            Sends the message and through socket informs the other user
            that the message has been received
            """
            if current_user.is_anonymous:
                return Message.create_response(jsonify({
                    'message': 'Unauthorized'
                })), 400
            if not a0.isdigit():
                return Message.create_response(jsonify({
                    'message': 'Bad request'
                })), 400
            uid = int(a0)
            user = auth.User.query.filter(auth.User.id == uid).first()
            msg = request.get_json().get('message')
            if not user or not msg:
                return Message.create_response(jsonify({
                    'message': 'Bad request'
                })), 400
            msg = MessageTable(current_user.id, user.id, msg)
            Message.db()['session'].add(msg)
            Message.db()['session'].commit()

            # Todo: receive the message through socket for the recepient
            # over here
            if Message.sock_sids().get(uid):
                Message.sock().emit('receive_msg', {
                    'sender': current_user.id,
                    'message': msg,
                    'updated_pics': get_updated_pic(current_user, user)
                }, room=Message.sock_sids()[uid])

            return Message.create_response(jsonify({
                'message': 'success',
                'updated_pics': get_updated_pic(user, current_user)
            }))
        return [receive_message, send_message]
