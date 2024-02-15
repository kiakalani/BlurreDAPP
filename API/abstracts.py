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

    @staticmethod
    @property
    def db(self) -> db.DBComps:
        """
        Getter method for accessing the database.
        :return: The database components of the application
        """
        db_comps: db.DBComps = current_app.config['DB']
        return db_comps

    def group_functions(self) -> dict:
        """
        This method groups all of the functions by their method and name of the
        operation.
        :return: A dictionary with the following structure:
        {Method: {RouteName: [Functions]}}
        """

        funcs = {}
        pattern = re.compile(r'^bp_(?P<method>[^_]+)_?(?P<route>[^_]?\S*)$')

        for func in dir(self):
            the_func = getattr(self, func)

            if hasattr(the_func, '__call__'):
                m = pattern.match(func)

                if m:
                    m = m.groupdict()
                    method, route = m.get('method'), m.get('route')
                    # making sure the method is valid
                    if method.upper() not in [
                        'GET', 'POST', 'PUT', 'HEAD', 'DELETE',
                        'PATCH', 'OPTIONS', 'CONNECT', 'TRACE'
                    ]:
                        continue
                    if not funcs.get(method):
                        funcs[method] = {}
                    if not funcs[method].get(route):
                        funcs[method][route] = [the_func] \
                            if inspect.getfullargspec(the_func).annotations.get('return') != list \
                                else the_func()
        return funcs

    def create_tmp_func(self, cmps):
        """
        Creates the function that combines all of the methods
        for the given route.
        :param: cmps: The components of the route.
        :return: A combined function that contains all the
        operations for different methods.
        """

        def ret_func(*args, **kwargs):
            for i in range(len(cmps['functions'])):
                if request.method == cmps['method'][i]:
                    return cmps['functions'][i](*args, **kwargs)
            return 'Not Implemented', 400

        return ret_func
        

    def assemble_functions(self) -> dict:
        """
        A method to assemble all of the functions with different
        methods together.
        :return: A dictionary containing all of the assembled
        functions.
        """

        funcs = self.group_functions()

        final_funcs = {}

        for method, functions  in funcs.items():
            method = method.upper()
            for fname in functions:
                
                # Supplying the information about the functions
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
                
                # Setting up the combiend functions for the operations.
                for n, cmps in final_funcs[fname].items():
                    cmbd_func = self.create_tmp_func(cmps)
                    final_funcs[fname][n]['function'] = cmbd_func    
                    

        return final_funcs




    def register_all(self) -> None:
        """
        A function to register the blueprint and all of the
        corresponding functions for routes.
        :return: None
        """
        funcs_to_register = self.assemble_functions()
        print(funcs_to_register)
        for route, contents in funcs_to_register.items():
            route = '/' + route
            if route != '/':
                route += '/'
            for nparams, comps in contents.items():
                t_rt = route
                for i in range(nparams):
                    t_rt += f'<a{i}>/'
                print(comps)
                print(t_rt)
                self.__bp.add_url_rule(
                    t_rt, t_rt, view_func = comps['function'], methods=comps['method']
                )
        current_app.register_blueprint(self.__bp)

