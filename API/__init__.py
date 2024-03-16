import os

from flask import Flask, request
from flask_login import current_user
from flask_cors import CORS
from flask_socketio import SocketIO
import db
import blueprints


    
class FlaskApp:
    """
    A class that is responsible for assembling the
    application together.
    """
    def __init__(self) -> None:
        """
        Constructor
        :return: None
        """
        self.__app = Flask('API', static_folder='static')
        self.__setup_config()
        self.__setup_socketio()
        with self.__app.app_context():
            self.__load_blueprints()

    def __setup_config(self) -> None:
        """
        Sets up the initial configurations for the app.
        :return: None
        """
        self.__app.config['DB'] = db.init_db()
        self.__app.config['DEBUG'] = False
        self.__app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY')
        app = self.__app
        @self.__app.teardown_appcontext
        def rm_sess(exception=None):
            if app.config['DB'].get('destroy'):
                app.config['DB']['destroy']()

    def __setup_socketio(self) -> None:
        """
        Sets up the socket io within the application.
        :return: None
        """

        socket = SocketIO(self.__app, cors_allowed_origins='*', engineio_logger=True, logger=True)
        self.__app.config['SOCKETIO'] = {'IO':socket, 'SIDS': {}}
        @socket.on('connect')
        def connect(auth):
            print(auth, 'tried to connect')
            if current_user.is_anonymous:
                return
            self.__app.config['SOCKETIO']['SIDS'][current_user.id] = request.sid

        @socket.on('disconnect')
        def disconnect(auth):
            if current_user.is_anonymous:
                return
            user_sids = self.__app.config['SOCKETIO']['SIDS']
            if current_user.id in user_sids:
                del user_sids[current_user.id]


    def __load_blueprints(self) -> None:
        """
        Loads the blueprints automatically into the
        flask application.
        :return: None
        """

        import blueprints.auth as auth
        

        for b in blueprints.get_all_bps():
            b().register_all()
        
        db.load_orms(self.__app)
        auth.init_login_manager()

    @property 
    def socket(self) -> SocketIO:
        """
        Returns the socket instance of the application
        :return: The socket instance of app.
        """

        return self.__app.config['SOCKETIO']['IO']
    
    @property
    def db(self) -> db.DBComps:
        """
        Provides the db components.
        :return: DBComps of the applications
        """

        return self.__app.config['DB']

    def run(self) -> None:
        """
        Runs the application.
        :return: None
        """
        CORS(self.__app, supports_credentials=True, origins='*')
        self.socket.run(self.__app, debug=self.__app.config['DEBUG'], host='0.0.0.0', port=3001)


__flask_app = FlaskApp()

def get_flask_app():
    """
    Getter for the flask app instance.
    :return: The flask app instance
    """

    return __flask_app
            
if __name__ == '__main__':
    get_flask_app().run()
