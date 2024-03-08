import os

from flask import Flask
from flask_login import current_user
from flask_cors import CORS
from flask_socketio import SocketIO

import db
import blueprints


    
class FlaskApp:
    def __init__(self):
        self.__app = Flask('API', static_folder='static')
        self.__setup_config()
        with self.__app.app_context():
            self.__load_blueprints()

    def __setup_config(self) -> None:
        self.__app.config['DB'] = db.init_db()
        self.__app.config['DEBUG'] = False
        self.__app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY')
        app = self.__app
        @self.__app.teardown_appcontext
        def rm_sess(exception=None):
            if app.config['DB'].get('destroy'):
                app.config['DB']['destroy']()

    def __load_blueprints(self) -> None:
        import blueprints.auth as auth
        

        for b in blueprints.get_all_bps():
            b().register_all()
        
        db.load_orms(self.__app)
        auth.init_login_manager()
        

    def run(self):
        CORS(self.__app, supports_credentials=True, origins='*')
        self.__app.run(debug=self.__app.config['DEBUG'], host="0.0.0.0", port=3001)

__flask_app = FlaskApp()

def get_flask_app():
    return __flask_app

# def get_app() -> Flask:
#     """
#     A function to setup the necessary configurations
#     for the flask application and return the instance.
#     :return: The flask application.
#     """

#     app = Flask('API', static_folder='static')
#     app.config['DB'] = db.init_db()
#     app.config['DEBUG'] = False
#     app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY')
#     with app.app_context():
#         db.load_orms(app)

#         from auth import Authorization, init_login_manager
#         Authorization().register_all()
#         init_login_manager()
#         from profile_imp import ProfileBP
#         ProfileBP().register_all()
#         from message import Message
#         Message().register_all()
#         from matches import MatchBP
#         MatchBP().register_all()
#         from swipe import SwipeBP
#         SwipeBP().register_all()

#     @app.teardown_appcontext
#     def rm_sess(exception=None):
#         if app.config['DB'].get('destroy'):
#             app.config['DB']['destroy']()
#     return app


# if __name__ == '__main__':
#     app = get_app()
#     CORS(app, supports_credentials=True, origins="*")
#     app.run(debug=app.config['DEBUG'], host="0.0.0.0", port=3001)
            
if __name__ == '__main__':
    get_flask_app().run()
