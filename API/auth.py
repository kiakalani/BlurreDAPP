import inspect

from flask_login import UserMixin
import abstracts

class Authorization(abstracts.BP):
    def __init__(self) -> None:
        super().__init__('auth')
    
    @staticmethod
    def bp_get():
        return 'Hello!'
    #/auth/signin/p/q
    @staticmethod
    def bp_get_signin() -> list:
        def no_param():
            return 'One param'
        def one_param(p):
            return 'Param' + p
        def two_param(p, q):
            return 'Two Param' + p + ' ' + q
        return [one_param, two_param, no_param]
    @staticmethod
    def bp_post_signin() -> list:
        def no_param():
            return 'One param'
        def one_param(p):
            return 'Param' + p
        def two_param(p, q):
            return 'Two Param' + p + ' ' + q
        return [one_param, two_param, no_param]

