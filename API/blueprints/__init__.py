import blueprints.abstracts as abstracts
import os
import importlib
from sqlalchemy.orm.decl_api import DeclarativeMeta
__modules = []
def __init_modules():
    if len(__modules) == 0:
        for name in os.listdir(os.path.join('blueprints')):
            mod_name = name[:-3]
            if name[-3:] != '.py' or mod_name == '__init__':
                continue
            mod = importlib.import_module(f'blueprints.{mod_name}')
            __modules.append(mod)

def get_all_bps() -> list[abstracts.BP]:
    __init_modules()
    ret_arr = []
    for m in __modules:
        for d in dir(m):
            if d == 'BP':
                continue
            attr = getattr(m, d)
            if isinstance(attr, type) and issubclass(attr, abstracts.BP):
                ret_arr.append(attr)
    return ret_arr

def get_all_orms() -> list[DeclarativeMeta]:
    __init_modules()
    ret_arr = []
    for m in __modules:
        for d in dir(m):
            attr = getattr(m, d)
            if isinstance(attr, DeclarativeMeta):
                ret_arr.append(attr)
    return ret_arr
                
