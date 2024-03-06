from flask import current_app, jsonify
from flask_login import current_user
from sqlalchemy import Integer, String, Column, and_, or_, text

import abstracts
class MatchTable(current_app.config['DB']['base']):
    __tablename__ = 'match'
    user1 = Column(Integer, primary_key=True)
    user2 = Column(Integer, primary_key=True)

    def __init__(self, user1, user2):
        self.user1 = user1
        self.user2 = user2


class MatchBP(abstracts.BP):
    def __init__(self) -> None:
        super().__init__('match')

    @staticmethod
    def bp_get():
        if current_user.is_anonymous:
            return MatchBP.create_response(jsonify({
                'message': 'Unauthorized'
            })), 400
        ids = MatchBP.db()['session'].execute(
            text(
                'SELECT u.id FROM user u WHERE u.id <> :uid AND NOT EXISTS ('
                    'SELECT * FROM match WHERE ('
                        '(user1=:uid AND user2=u.id) OR (user1=u.id AND user2=:uid)'
                    ')'
                ');'
            ),
            {'uid': current_user.id}
        ).all()
        ids = ids[:10]
        ids = [i[0] for i in ids]
        print(ids)
        return MatchBP.create_response(jsonify({
            'message': 'Success',
            'ids': ids
        })), 200
        