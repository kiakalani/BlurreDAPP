from flask import current_app, jsonify, request
from flask_login import current_user
from sqlalchemy import Integer, String, Column, and_, or_, text

import abstracts
import auth


class MatchTable(current_app.config['DB']['base']):
    """
    The table for indicating the matches between
    two users.
    """
    __tablename__ = 'match'
    user1 = Column(Integer, primary_key=True)
    user2 = Column(Integer, primary_key=True)
    def __init__(self, user1, user2):
        self.user1 = user1
        self.user2 = user2

class MatchBP(abstracts.BP):
    def __init__(self) -> None:
        super().__init__('match')
    
    def bp_get():
        return MatchBP.create_response(jsonify({
            'todo': 'Create a mechanism for this to provide the'
            'id of the users that the current user is matched with'
        }))
    
    def bp_post_profile():
        return MatchBP.create_response(jsonify({
            'todo': 'Create a mechanism for getting the details from the'
            'specific profile'
        }))
