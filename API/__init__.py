from flask import Flask

import db

    

def get_app() -> Flask:
    """
    A function to setup the necessary configurations
    for the flask application and return the instance.
    :return: The flask application.
    """

    app = Flask('API', static_folder='static')
    app.config['DB'] = db.init_db()

    with app.app_context():
        from auth import Authorization
        Authorization().register_all()

    @app.teardown_appcontext
    def rm_sess(exception=None):
        if app.config['DB'].get('destroy'):
            app.config['DB']['destroy']()

    return app


if __name__ == '__main__':
    get_app().run()
