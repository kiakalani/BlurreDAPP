import inspect
import re
from flask import current_app, Blueprint, request

import db

class BP:
    """
    An abstract class for creating blueprints.
    """
    def __init__(self, name: str) -> None:
        """
        Constructor.
        :param: name: The name of the blueprint.
        """
        self.__name = name
        self.__bp = Blueprint(name, __name__, url_prefix=f'/{name}')
    
    def register_method(self, func) -> None:
        if not hasattr(func, '__call__'):
            return
        # print(func.__name__)
        # Starts with get or post and ends with the route
        pattern = re.compile(r'^bp_(?P<method>[^_]+)_?(?P<route>[^_]?\S*)$')
        # Name of the function
        fname = func.__name__
        # Making sure the function is supposed to be for routing
        m = pattern.match(fname)
        if not m:
            return
        m = m.groupdict()
        m['method'] = m['method'].upper()
        if m['method'] not in [
            'GET', 'POST', 'PUT', 'HEAD', 'DELETE',
            'PATCH', 'OPTIONS', 'CONNECT', 'TRACE'
        ]:
            return
        
        route, method = m['route'], m['method']
        f_inspect = inspect.getfullargspec(func)
        the_route = f'/{route}'

        # If return type is a list, this would mean the function is overloaded.
        # Therefore, multiple functions would need to be added.
        if f_inspect.annotations.get('return') == list:
            for f in func():
                tr = the_route
                args = inspect.getfullargspec(f).args
                # Creating the url for each function
                for i in range(0, len(args)):
                    if tr == '/':
                        tr += '<' + args[i] + '>'
                    else:
                        tr += '/<' + args[i] + '>'
                # Adding the route
                self.__bp.add_url_rule(tr, tr, view_func=f, methods=[method])
        else:
            self.__bp.add_url_rule(the_route, the_route, view_func=func, methods=[method])

    @staticmethod
    @property
    def db(self) -> db.DBComps:
        db_comps: db.DBComps = current_app.config['DB']
        return db_comps

    def group_functions(self):
        funcs = {}
        pattern = re.compile(r'^bp_(?P<method>[^_]+)_?(?P<route>[^_]?\S*)$')
        for func in dir(self):
            the_func = getattr(self, func)
            if hasattr(the_func, '__call__'):
                m = pattern.match(func)
                if m:
                    m = m.groupdict()
                    method, route = m.get('method'), m.get('route')
                    if method.upper() not in [
                        'GET', 'POST', 'PUT', 'HEAD', 'DELETE',
                        'PATCH', 'OPTIONS', 'CONNECT', 'TRACE'
                    ]:
                        continue
                    if not funcs.get(method):
                        funcs[method] = {}
                    if not funcs[method].get(route):
                        funcs[method][route] = [the_func] if inspect.getfullargspec(the_func).annotations.get('return') != list else the_func()
        return funcs

    def assemble_functions(self):
        funcs = self.group_functions()
        final_funcs = {}
        for method, functions  in funcs.items():
            method = method.upper()
            for fname in functions:

                for f in functions[fname]:
                    if not final_funcs.get(fname):
                        final_funcs[fname] = {}
                    num_args = len(inspect.getfullargspec(f).args)
                    print(num_args)                    
            
                    if not final_funcs[fname].get(num_args):
                        final_funcs[fname][num_args] = {'method': [method], 'functions': [f]}
                    else:
                        final_funcs[fname][num_args]['method'].append(method)
                        final_funcs[fname][num_args]['functions'].append(f)
                
                for n, cmps in final_funcs[fname].items():
                    def cmbd_func(*args, **kwargs):
                        for i in range(len(cmps['functions'])):
                            if request.method == cmps['method'][i]:
                                return cmps['functions'][i](*args, **kwargs)
                        
                    final_funcs[fname][n]['function'] = cmbd_func
        import pprint; pprint.pprint(final_funcs)
                    
                            
                    

        return final_funcs




    def register_all(self):
        funcs_to_register = self.assemble_functions()
        print(funcs_to_register)
        for route, contents in funcs_to_register.items():
            route = '/' + route
            if route != '/':
                route += '/'
            for nparams, comps in contents.items():
                t_rt = route
                for i in range(nparams):
                    t_rt += f'<arg{i}>/'
                print(comps)
                print(t_rt)
                self.__bp.add_url_rule(
                    t_rt, t_rt, view_func = comps['function'], methods=comps['method']
                )
        current_app.register_blueprint(self.__bp)
