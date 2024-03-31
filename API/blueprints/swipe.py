import math
from flask import jsonify, current_app, request
from flask_login import current_user
from sqlalchemy import Column, Integer, String, and_, or_, text, exists, extract, func

import blueprints.auth as auth
import blueprints.matches as matches
import blueprints.abstracts as abstracts
import blueprints.profile_imp as profile_imp

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


class SwipeBP(abstracts.BP):
    """
    The blueprint for matching functionality
    """
    def __init__(self) -> list:
        super().__init__('swipe')
    @staticmethod
    def create_filter_query() -> str:
        today = auth.datetime.datetime.today()
        preferences: profile_imp.ProfilePreference = profile_imp.ProfilePreference.query.filter(
            profile_imp.ProfilePreference.email == current_user.email
        ).first()
        location: profile_imp.UserLocation = profile_imp.UserLocation.query.filter(
            profile_imp.UserLocation.email == current_user.email
        ).first()
        users = SwipeBP.db()['session'].query(auth.User).filter(
            and_(
                auth.User.id != current_user.id,
                ~exists().where(
                    and_(
                        SwipeTable.user == current_user.id,
                        SwipeTable.swiped == auth.User.id
                    )
                )
            )
        ).filter(
            and_(
                and_(
                    (today.year - extract('year', auth.User.birthday)) <= preferences.age,
                    (today.year - extract('year', auth.User.birthday)) >= preferences.min_age
                ),
                and_(
                    exists().where(
                        and_(
                            and_(
                                profile_imp.Profile.email == auth.User.email,
                                or_(
                                    profile_imp.Profile.orientation == preferences.orientation,
                                    preferences.orientation == 'Everyone'
                                )
                            ),
                            or_(
                                profile_imp.Profile.gender == preferences.gender,
                                preferences.gender == 'Everyone'
                            )
                        ),
                    ),
                    exists().where(
                        and_(
                            profile_imp.UserLocation.email == auth.User.email,
                            or_(
                                preferences.distance > 100,
                                func.acos(
                                    func.sin(func.radians(location.latitude)) * func.sin(func.radians(profile_imp.UserLocation.latitude)) +
                                    func.cos(func.radians(location.latitude)) * func.cos(func.radians(profile_imp.UserLocation.latitude)) *
                                    func.cos(func.radians(profile_imp.UserLocation.longitude - location.longitude))
                                ) * 6371 <= preferences.distance 
                            )
                        )
                    )
                )
            )
        ).all()
        return [u.id for u in users]
        # users = [u.id for u in users]
        
        # statement = f'SELECT u.id FROM user u WHERE u.id <> :uid AND NOT EXISTS (' +\
        #     'SELECT * FROM swipe WHERE (' +\
        #         '(user=:uid AND swiped=u.id)' +\
        #     ')' +\
        # ')'
        # statement += f' AND user.age >= {preferences.age}'
        # if preferences.orientation != 'Everyone':
        #     statement += f' AND user.orientation = {preferences.orientation}'
        # if preferences.gender != 'Everyone':
        #     statement += f' AND user.gender = {preferences.gender}'
        # user_location: profile_imp.UserLocation = profile_imp.UserLocation.query.filter(
        #     profile_imp.UserLocation.email == current_user.email
        # ).first()
        # lat = math.radians(user_location.latitude)
        # long = math.radians(user_location.longitude)
        # # statement += f' AND EXISTS('+\
        # #     'SELECT * from user_location loc WHERE loc.email = u.email AND ' +\
        # #     f'ACOS(SIN({lat}) * SIN(RADIANS(loc.latitude)) + COS({lat}) * COS(RADIANS(loc.latitude)) * COS(RADIANS(loc.longitude) - {long})) * 6371 <= {preferences.distance}' +\
        # # ')'
        # statement += ';'
        # return statement
        
    @staticmethod
    def bp_get():
        """
        A method to return the id of the upcoming users
        for potential matches. TODO: This needs to include more
        stuff such as gender, orientation etc.
        """

        if current_user.is_anonymous:
            return SwipeBP.create_response(jsonify({
                'message': 'Unauthorized'
            })), 400
        ids = SwipeBP.create_filter_query()
        ids = ids[:10]
        return SwipeBP.create_response(jsonify({
            'message': 'Success',
            'ids': ids
        })), 200
    
    @staticmethod
    def bp_post():
        """
        A method to perform the swipe action on a user.
        This method would store a match in case both users
        have swipped right on each other.
        """
        if current_user.is_anonymous:
            return SwipeBP.create_response(jsonify({
                'message': 'Unauthorized'
            })), 400

        user_req = request.get_json()
        swiped = user_req.get('swiped')
        action = user_req.get('action')

        # Error checkings
        if action not in ['left', 'right'] or not swiped or (not isinstance(swiped, int) and not swiped.isdigit()):
            return SwipeBP.create_response(jsonify({
                'message': 'Invalid request'
            })), 400
        swiped = int(swiped)
        dest_user = auth.User.query.filter(auth.User.id == swiped).first()
        if not dest_user:
            return SwipeBP.create_response(jsonify({
                'message': 'Invalid request'
            })), 400
        
        # This means swiping has already happened
        if SwipeTable.query.filter(
            and_(SwipeTable.user == current_user.id, SwipeTable.swiped == swiped)
        ).first():
            return SwipeBP.create_response(jsonify({
                'message': 'Invalid request'
            })), 400
        
        # Adding the swipe action
        inst = SwipeTable(current_user.id, swiped, action)
        SwipeBP.db()['session'].add(inst)

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
                a_match = matches.MatchTable(swiped, current_user.id)
                # Todo: Notify within the socket
                SwipeBP.db()['session'].add(a_match)
        SwipeBP.db()['session'].commit()
        
        return SwipeBP.create_response(jsonify({
            'message': 'Success'
        })), 200
