from flask import Flask

app = Flask('API', static_folder='static')

def get_app() -> Flask:
    """
    A function to setup the necessary configurations
    for the flask application and return the instance.
    :return: The flask application.
    """

    app = Flask('API', static_folder='static')
    with app.app_context():
        pass
    return app
app.route('/api')
def handle_api():
    return ''


if __name__ == '__main__':
    get_app().run()
