# xmlrpc: Interface to *XMLRPCServer supporting help info etc


import sys, socket, traceback, datetime, os.path, textwrap
from string import Template
from SimpleXMLRPCServer import SimpleXMLRPCServer
from DocXMLRPCServer import DocCGIXMLRPCRequestHandler
from nexus.util import file_utils

class Failure (Exception):
    """An error which should be reported to the client

    The dispatcher returns the tuple (False, error-message) to the client
    if this exception is raised
    """
    pass

class CustomFailure (Exception):
    """An error which should be reported to the client

    The dispatcher calls the wrap_custom_failure wrapper if this exception is
    raised
    """
    pass

def _make_desc(known_values):
    offset = 16
    namelen = max(len(name) for name, desc in known_values) + 1
    pad = ' ' * (offset + namelen + 1)
    res = []

    for name, desc in known_values:
        label = '%*s%-*s ' % (offset, '', namelen, name + ':')
        res.append(textwrap.fill(desc, width=90-offset,
                                 initial_indent=label, subsequent_indent=pad))

    return '\n' + '\n\n'.join(res)

class _HandlerInfo (object):
    def __init__(self, args, raw_help, doc_keywords):
        if doc_keywords is not None:
            vars = dict((k, _make_desc(v)) for k, v in doc_keywords.iteritems())
            subst_help = Template(raw_help).substitute(vars)
        else:
            subst_help = raw_help

        if "\n" in subst_help:
            first_line, rest = subst_help.split('\n', 1)
            dedented_help = "\n".join([ first_line, textwrap.dedent(rest) ])
        else:
            dedented_help = subst_help

        self.args = args
        self.help = '\n%s' % dedented_help

def handler(args, doc_keywords=None):
    def decorate(f):
        doc = f.__doc__
        assert doc is not None, "No doc string for %s" % f.__name__
        f.handler_info = _HandlerInfo(args, doc, doc_keywords)
        return f
    return decorate

def add_cmdline_options(parser, appname=None):
    logname = appname or os.path.splitext(os.path.basename(sys.argv[0]))[0]
    default_logpath = "/usr/local/ntt/%s/logs/%s.log" % (logname, logname)
    parser.add_option(
        '--server-logpath', default=default_logpath,
        help="Log errors to LOGPATH (default %default)")

    parser.add_option(
        '--server-port', type='int',
        help="Listen on the specified port rather than running as CGI script")

class RequestHandler (object):
    def _listMethods(self):
        methods = []
        for name, func in sorted(self.__class__.__dict__.items()):
            if hasattr(func, 'handler_info'):
                methods.append(name)
        return methods

    def _get_method_argstring(self, method_name):
        args = self._get_method(method_name).handler_info.args
        argstr = ', '.join([ "%s:%s" % (argname, valspec)
                             for argname, valspec in sorted(args.items()) ])
        if argstr == '':
            return '({})'
        else:
            return '({ %s })\n' % argstr

    def _get_method(self, name):
        func = getattr(self, name)
        assert func.handler_info is not None   # To check it's really a handler
        return func

    def _methodHelp(self, method_name):
        method = self._get_method(method_name)
        return method.handler_info.help

    wrap_request_result = staticmethod(lambda result: result)
    wrap_custom_failure = staticmethod(lambda result: str(result))

    def _dispatch(self, *args):
        try:
            name, (params,) = args
            result = self._get_method(name)(**params)
        except Failure, why:
            return [ False, str(why) ]
        except CustomFailure, why:
            return self.wrap_custom_failure(why)
        except Exception, why:
            sep = '-' * 70 + '\n'
            sys.stderr.write("\n" + sep)
            sys.stderr.write("%s: Unexpected exception:\n\n" %
                             datetime.datetime.now().isoformat())
            traceback.print_exc(200, sys.stderr)
            sys.stderr.write(sep)
            raise why
        return self.wrap_request_result(result)


def handle_requests(handler, server_help, optvals):
    assert isinstance(handler, RequestHandler), \
           "Handler object type %s is not a subclass of %s" % \
           (type(handler), RequestHandler)

    server_port = optvals.server_port

    if server_port is not None:
        server = SimpleXMLRPCServer(('localhost', server_port))
    else:
        server = DocCGIXMLRPCRequestHandler()
        server.set_server_name('SAB at %s' % socket.gethostname())
        server.set_server_documentation(server_help)

        sys.stderr = file_utils.TimestampWrapper(
            open(optvals.server_logpath, "a"))

    server.register_instance(handler)
    server.register_introspection_functions()

    # print handler._get_method_argstring('install_monitors')

    if server_port is not None:
        server.serve_forever()
    else:
        server.handle_request()
