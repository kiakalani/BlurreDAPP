import abstracts
from flask import jsonify

class Swipe(abstracts.BP):
    def __init__(self) -> None:
        super().__init__('swipe')
    def bp_post() -> list:
        def matching_users():
            return jsonify({
                'Todo': '''
                Implement machine learning algorithm that returns matching
                users
                '''
            })
        def swipe(user):
            return jsonify({
                'Todo': '''
                Implement swiping left and write
                '''
            })
        return [matching_users, swipe]