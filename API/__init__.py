from flask import Flask

app = Flask('API', static_folder='static')


app.route('/api')
def handle_api():
    return ''


if __name__ == '__main__':
    app.run()