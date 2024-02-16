import os
from flask import Flask
from flask_cors import CORS
import db

    

def get_app() -> Flask:
    """
    A function to setup the necessary configurations
    for the flask application and return the instance.
    :return: The flask application.
    """

    app = Flask('API', static_folder='static')
    app.config['DB'] = db.init_db()
    app.config['DEBUG'] = False
    app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY')
    app.config['SESSION_COOKIE_SECURE'] = False  # Only send cookies over HTTPS
    app.config['SESSION_COOKIE_SAMESITE'] = 'None'  # Allow cookies to be sent with cross-site requests
    with app.app_context():
        db.load_orms(app)

        from auth import Authorization, init_login_manager
        Authorization().register_all()
        init_login_manager()

    @app.teardown_appcontext
    def rm_sess(exception=None):
        if app.config['DB'].get('destroy'):
            app.config['DB']['destroy']()
    return app


if __name__ == '__main__':
    app = get_app()
    CORS(app, supports_credentials=True, origins="*")
    app.run(debug=app.config['DEBUG'], host="0.0.0.0", port=3001)
