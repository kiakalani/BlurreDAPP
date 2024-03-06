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

class SwipeTable(current_app.config['DB']['base']):
    """
    The table for storing the swipe action.
    """
    __tablename__ = 'swipe'

    user = Column(Integer, primary_key=True)
    swiped = Column(Integer, primary_key=True)
    action = Column(String)

    def __init__(self, user, swiped, action):
        self.user = user
        self.swiped = swiped
        self.action = action


class MatchBP(abstracts.BP):
    """
    The blueprint for matching functionality
    """
    def __init__(self) -> None:
        super().__init__('match')

    @staticmethod
    def bp_get():
        """
        A method to return the id of the upcoming users
        for potential matches. TODO: This needs to include more
        stuff such as gender, orientation etc.
        """

        if current_user.is_anonymous:
            return MatchBP.create_response(jsonify({
                'message': 'Unauthorized'
            })), 400
        ids = MatchBP.db()['session'].execute(
            text(
                'SELECT u.id FROM user u WHERE u.id <> :uid AND NOT EXISTS ('
                    'SELECT * FROM swipe WHERE ('
                        '(user=:uid AND swiped=u.id)'
                    ')'
                ');'
            ),
            {'uid': current_user.id}
        ).all()
        ids = ids[:10]
        ids = [i[0] for i in ids]
        return MatchBP.create_response(jsonify({
            'message': 'Success',
            'ids': ids
        })), 200
    
    @staticmethod
    def bp_post_swipe():
        """
        A method to perform the swipe action on a user.
        This method would store a match in case both users
        have swipped right on each other.
        """
        if current_user.is_anonymous:
            return MatchBP.create_response(jsonify({
                'message': 'Unauthorized'
            })), 400

        user_req = request.get_json()
        swiped = user_req.get('swiped')
        action = user_req.get('action')

        # Error checkings
        if action not in ['left', 'right'] or not swiped or (not isinstance(swiped, int) and not swiped.isdigit()):
            return MatchBP.create_response(jsonify({
                'message': 'Invalid request'
            })), 400
        swiped = int(swiped)
        dest_user = auth.User.query.filter(auth.User.id == swiped).first()
        if not dest_user:
            return MatchBP.create_response(jsonify({
                'message': 'Invalid request'
            })), 400
        
        # This means swiping has already happened
        if SwipeTable.query.filter(
            and_(SwipeTable.user == current_user.id, SwipeTable.swiped == swiped)
        ).first():
            return MatchBP.create_response(jsonify({
                'message': 'Invalid request'
            })), 400
        
        # Adding the swipe action
        inst = SwipeTable(current_user.id, swiped, action)
        MatchBP.db()['session'].add(inst)

        if action == 'right':
            if SwipeTable.query.filter(
                and_(
                    and_(
                        SwipeTable.user == swiped,
                        SwipeTable.swiped == current_user.id
                    ),
                    SwipeTable.action == action
                )
            ).first() is not None:
                # Means we have a match
                a_match = MatchTable(swiped, current_user)
                # Todo: Notify within the socket
                MatchBP.db()['session'].add(a_match)
        MatchBP.db()['session'].commit()
        
        return MatchBP.create_response(jsonify({
            'message': 'Success'
        })), 200
        