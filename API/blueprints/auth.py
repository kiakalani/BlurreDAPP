import inspect
import datetime
import re

from flask_login import UserMixin, LoginManager, login_user, current_user, logout_user
from flask import request, jsonify, current_app, make_response
from werkzeug.security import generate_password_hash,\
    check_password_hash

from sqlalchemy import Column, Integer, String
import blueprints.abstracts as abstracts
import blueprints.profile_imp as profile_imp

class User(UserMixin, current_app.config['DB']['base']):
    """
    User class for database representation and session
    handling.
    """

    __tablename__ = 'user'
    id = Column(Integer, primary_key=True)
    email = Column(String, unique=True)
    name = Column(String)
    birthday = Column(String)
    password = Column(String, nullable=False)

    def __init__(self, email, name, birthday, password):
        self.email = email
        self.name = name
        self.birthday = birthday
        self.password = password

def init_login_manager() -> None:
    """
    This method initializes the login manager.
    :return: None
    """

    mgr = LoginManager()
    mgr.init_app(current_app)
    @mgr.user_loader
    def usr_gt(id):
        return User.query.get(int(id))
    
def get_age(birthday: datetime.datetime) -> int:
    """
    A method to provide the age of the person from their
    birthday.
    :param: birthday: a datetime instance specifying the
    birthday of a person.
    :return: an integer indicating the age of the person.
    """

    today = datetime.datetime.now()
    return today.year - birthday.year - (
        1 if (
            (today.month, today.day) < (birthday.month, birthday.day)
        ) else 0
    )

def bday_str_to_datetime(bstr: str) -> datetime.datetime:
    """
    A method to convert string birthday to a datetime instance.
    :param: bstr: The string representation of the birthday.
    :return: a datetime instance containing the birthday
    """

    bd_p = re.compile(r'^(?P<month>\d+)-(?P<day>\d+)-(?P<year>\d\d\d\d)$')
    m = bd_p.match(bstr)
    if not m:
        return None
    return datetime.datetime(int(m['year']), int(m['month']), int(m['day']))

class Authorization(abstracts.BP):
    """
    The authorization blueprint class.
    """
    def __init__(self) -> None:
        super().__init__('auth')
    
    @staticmethod
    def bp_post_signin():
        """
        Post request for signing in.
        """

        # Validating the login the status before
        # the operation
        if not current_user.is_anonymous:
            return Authorization.create_response(
                jsonify({
                    'message': 'Bad request'
                })
            ), 400

        json_req = request.get_json()
        email = json_req.get('email')
        passwd = json_req.get('password')
        print(json_req)
        # Valdiating the provided variables
        if not email or not passwd:
            return Authorization.create_response(
                jsonify({
                    'message': 'Bad Request'
                })
            ), 400
        user = User.query.filter(User.email == email).first()
        # Making sure the user exists
        if not user:
            return Authorization.create_response(
                jsonify({
                    'message': 'Bad Request'
                })
            ), 400

        # If password is correct, login and provide the success
        # message to user
        pass_correct = check_password_hash(user.password, passwd)
        if pass_correct:

            login_user(user)
            return Authorization.create_response(jsonify({
                'message': 'Login Successful'
            })), 200
        
        # Means the password was wrong
        return Authorization.create_response(
            jsonify({
                'message': 'Bad request'
            })
        ), 400

    @staticmethod
    def bp_post_signup():
        """
        Post request for signing up.
        """

        # If logged in, this operation should not be permitted
        if not current_user.is_anonymous:
            return Authorization.create_response(
                jsonify({
                    'message': 'Bad request'
                })
            ), 400

        json_req = request.get_json()
        email = json_req.get('email')
        name = json_req.get('name')
        birthday = json_req.get('birthday')
        passwd = json_req.get('password')
        retype_passwd = json_req.get('repeat_password')
        
        # Validating the provided parameters exist
        if not email or not passwd or not name or not birthday or not retype_passwd:
            return Authorization.create_response(
                jsonify({
                    'message': 'Missing a required field'
                })
            ), 400

        if passwd != retype_passwd:
            return Authorization.create_response(
                jsonify({
                    'message': 'Passwords do not match'
                })
            ), 400

        if len(passwd) < 6:
            return Authorization.create_response(
                jsonify({
                    'message': 'The password length has to be at least 6 characters'
                })
            ), 400
        
        bday_dt = bday_str_to_datetime(birthday)
        if not bday_dt:
            return Authorization.create_response(
                jsonify({
                    'message': 'Invalid syntax provided for birthday'
                })
            ), 400
        
        if get_age(bday_dt) < 18:
            return Authorization.create_response(
                jsonify({
                    'message': 'You are too young to sign up for this application.'
                })
            ), 400
        
        
        

        user = User.query.filter(User.email == email).first()

        # This means the email already exists. So they should not be
        # allowed to create the user
        if user:
            return Authorization.create_response(
                jsonify({
                    'message': 'Bad Request'
                })
            ), 400

        new_usr = User(email, name, birthday, generate_password_hash(passwd))
        new_profile = profile_imp.Profile(email)
        Authorization.db()['session'].add(new_usr)
        Authorization.db()['session'].add(new_profile)
        Authorization.db()['session'].commit()

        return Authorization.create_response(
            jsonify({
                'message': 'Successful'
            })
        ), 200

    @staticmethod
    def bp_post_signout():
        """
        Post request for logging out from the app.
        """
        # Not logged in to be considered for signing out
        if current_user.is_anonymous:
            return Authorization.create_response(
                jsonify({
                    'message': 'Bad Request'
                })
            ), 400

        logout_user()
        return Authorization.create_response(
            jsonify({
                'message': 'Success'
            })
        ), 200
    
    @staticmethod
    def bp_post_logged_in():
        """
        A method in server that indicates whether the user
        has logged in or not.
        """

        return Authorization.create_response(
            jsonify({
                'logged_in': not current_user.is_anonymous
            })
        ), 200


