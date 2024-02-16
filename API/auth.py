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
        if not current_user.is_anonymous:
            return jsonify({'message': 'Bad request'}), 400
        json_req = request.get_json()
        username = json_req.get('username')
        passwd = json_req.get('password')
        if not username or not passwd:
            return jsonify({'message': 'Bad Request'}), 400
        user = User.query.filter(User.name == username).first()
        if not user:
            return jsonify({'message': 'Bad Request'}), 400
        pass_correct = check_password_hash(user.password, passwd)

        if pass_correct:
            login_user(user)
            response = make_response(jsonify({'message': 'Login Successful'}))
            response.set_cookie('your_cookie_name', 'cookie_value')
            return response, 200
        
        return jsonify({'message': 'Bad request'}), 400

    @staticmethod
    def bp_post_signup():
        """
        Post request for signing up.
        """

        if not current_user.is_anonymous:
            print(1)
            return jsonify({'message': 'Bad request'}), 400
        json_req = request.get_json()
        username = json_req.get('username')
        passwd = json_req.get('password')
        if not username or not passwd:
            print(2)
            return jsonify({'message': 'Bad Request'}), 400
        user = User.query.filter(User.name == username).first()
        if user:
            print(3)
            return jsonify({'message': 'Bad Request'}), 400
        new_usr = User(username, generate_password_hash(passwd))
        Authorization.db()['session'].add(new_usr)
        Authorization.db()['session'].commit()

        return jsonify({'message': 'Successfull'}), 200
    @staticmethod
    def bp_post_signout():
        """
        Post request for logging out from the app.
        """

        if current_user.is_anonymous:
            return jsonify({'message': 'Bad Request'}), 400
        logout_user()
        return jsonify({'message': 'success'}), 200

