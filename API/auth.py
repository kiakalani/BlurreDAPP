import inspect

from flask_login import UserMixin, LoginManager, login_user, current_user, logout_user
from flask import request, jsonify, current_app, make_response
from werkzeug.security import generate_password_hash,\
    check_password_hash

from sqlalchemy import Column, Integer, String
import abstracts

class User(UserMixin, current_app.config['DB']['base']):
    """
    User class for database representation and session
    handling.
    """

    __tablename__ = 'user'
    id = Column(Integer, primary_key=True)
    name = Column(String, unique=True)
    password = Column(String, nullable=False)

    def __init__(self, name, password):
        self.name = name
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
        username = json_req.get('username')
        passwd = json_req.get('password')

        # Valdiating the provided variables
        if not username or not passwd:
            return Authorization.create_response(
                jsonify({
                    'message': 'Bad Request'
                })
            ), 400

        user = User.query.filter(User.name == username).first()
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
        username = json_req.get('username')
        passwd = json_req.get('password')
        
        # Validating the provided parameters exist
        if not username or not passwd:
            return Authorization.create_response(
                jsonify({
                    'message': 'Bad Request'
                })
            ), 400

        user = User.query.filter(User.name == username).first()

        # This means the username already exists. So they should not be
        # allowed to create the user
        if user:
            return Authorization.create_response(
                jsonify({
                    'message': 'Bad Request'
                })
            ), 400

        new_usr = User(username, generate_password_hash(passwd))
        Authorization.db()['session'].add(new_usr)
        Authorization.db()['session'].commit()

        return Authorization.create_response(
            jsonify({
                'message': 'Successfull'
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


