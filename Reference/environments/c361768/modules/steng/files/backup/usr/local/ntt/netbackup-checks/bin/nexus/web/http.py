# $URL: svn+ssh://svn.eu.verio.net/usr/local/verio/svn/nexus/trunk/lib/python/nexus/web/http.py $
# $Id: http.py 12359 2007-10-17 20:56:03Z jsalter $

import cgi
import cgitb;

CONTENT_TYPE_HTML = 'text/html'
CONTENT_TYPE_TEXT = 'text/plain'

class WebPage:

    def __init__(self, content_type=None, html_stack=False):
        self._content = ''
        self._params = cgi.FieldStorage()

        if html_stack:
            self.want_html_stack()

        if content_type is None:
            self._content_type = CONTENT_TYPE_HTML
        else:
            self._content_type = content_type

    def want_html_stack(self):
        cgitb.enable()

    def add(self, content):
        self._content += content

    def display(self):
        print 'Content-Type: %s\n' % self._content_type
        print self._content

    def has_param(self, param):
        return self._params.has_key(param)

    def get_param(self, param):
        if not self._params.has_key(param):
            raise 'Parameter not set: %s' % param
        return self._params[param]
