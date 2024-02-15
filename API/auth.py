import inspect

from flask_login import UserMixin
import abstracts

class Authorization(abstracts.BP):
    def __init__(self) -> None:
        super().__init__('auth')
    
    @staticmethod
    def bp_get():
        return 'Hello!'

    @staticmethod
    def bp_get_signin() -> list:
        def no_param():
            return 'One param'
        def one_param(a0):
            return 'Param' + a0
        def two_param(a0, a1):
            return 'Two Param' + a1 + ' ' + a0
        return [one_param, two_param, no_param]

    @staticmethod
    def bp_post_signin() -> list:
        def one_param(a0):
            return 'Post Param' + a0
        def two_param(a0, a1):
            return 'Post Two Param' + a0 + ' ' + a1
        return [one_param, two_param]
