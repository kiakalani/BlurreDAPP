from flask import current_app, jsonify, request
from flask_login import current_user
from sqlalchemy import Integer, String, Column, and_, or_, text

import blueprints.abstracts as abstracts
import blueprints.auth as auth


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

def get_matches() -> list:
    """
    Getter for matches of the users.
    :return: a list containing the id of the 
    users that are matched with the current user.
    """
    if current_user.is_anonymous:
        return {}
    
    # Getting the users that have matched with the current user
    users = MatchTable.query.filter(
        or_(
            MatchTable.user1 == current_user.id,
            MatchTable.user2 == current_user.id
        )
    ).all()

    # We want to return only the id of these users as a response
    users = [
        (u.user1 if u.user2 == current_user.id else u.user2) for u in users
    ]

    return users

class MatchBP(abstracts.BP):
    def __init__(self) -> None:
        super().__init__('match')
    
    def bp_get():
        """
        A method that provides the id of all users that
        have matched the current user.
        """
        # Error checking
        if current_user.is_anonymous:
            return MatchBP.create_response(jsonify({
                'message': 'Unauthorized'
            })), 400
        
        # Getting the users that have matched with the current user
        users = get_matches()
        return MatchBP.create_response(jsonify({
            'message': 'Success',
            'response': users
        }))

    def bp_post_unmatch():
        """
        A method to unmatch a user.
        """

        # error checking the authorization
        if current_user.is_anonymous:
            return MatchBP.create_response(jsonify({
                'message': 'Unauthorized'
            })), 400
        
        resp = request.get_json()
        unmatched = resp.get('unmatched')

        # error checking the unmatch request
        if not unmatched or not isinstance(unmatched, str) or not unmatched.isdigit():
            return MatchBP.create_response(jsonify({
                'message': 'Bad request'
            })), 400
        unmatched = int(unmatched)

        # Finding the corresponding match item
        match_inst = MatchTable.query.filter(
            or_(
                and_(
                    MatchTable.user1 == current_user.id,
                    MatchTable.user2 == unmatched
                ),
                and_(
                    MatchTable.user1 == unmatched,
                    MatchTable.user2 == current_user.id
                )
            )
        ).first()

        # Error checking whether the two users were already
        # matched
        if not match_inst:
            return MatchBP.create_response(jsonify({
                'message': 'Bad request'
            })), 400
        
        # deleting the match instance
        MatchBP.db()['session'].delete(match_inst)
        MatchBP.db()['session'].commit()

        return MatchBP.create_response(jsonify({
            'message': 'Success'
        }))

