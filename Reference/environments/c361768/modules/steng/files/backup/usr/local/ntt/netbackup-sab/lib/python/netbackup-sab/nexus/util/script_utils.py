import sys, os, os.path, optparse, datetime, fcntl, signal, errno

class FatalError (Exception):
    pass

class UsageError (Exception):
    pass

_Logfile = None

def fatal(mesg):
    raise FatalError(mesg)

def _maybe_log(mesg):
    if _Logfile:
        try:
            _Logfile.write('%s UTC %6d: %s\n' % (
                datetime.datetime.utcnow().isoformat(), os.getpid(), mesg))
            _Logfile.flush()
        except EnvironmentError, why:
            sys.stderr.write("Warning: Error writing to log file %s: %s\n" %
                             (_Logfile.name, why))

def note(mesg):
    _maybe_log(mesg)
    sys.stderr.write("%s\n" % mesg)

def chat(mesg):
    _maybe_log(mesg)
    sys.stdout.write("%s\n" % mesg)
    sys.stdout.flush()

def _add_script_options(parser, default_logpath, default_lockfile):
    if default_logpath:
        parser.add_option(
            '--logfile', metavar='PATH', default=default_logpath,
            help=('Log progress messages to PATH as well as stdout and stderr '
                  '(default %default)'))

    if default_lockfile:
        parser.add_option(
            '--lockfile', metavar='PATH', default=default_lockfile,
            help=('Use a lockfile (default %default)'))

    parser.add_option('--pass-errors', action='store_true',
                      help='Dump full stack traces on errors')

def add_verbose_option(parser):
    parser.add_option('--verbose', action='store_true',
                      help='Show progress messages.')

def run_with_options(func, options, *args):
    # If we're being run with stdout going somewhere different than stderr
    # (e.g. under minder --log-stdout), we send any fatal error message to
    # stdout as well as stderr so we can see what happened when we look at
    # the log file.
    dup_fatals_to_stdout = not os.path.sameopenfile(sys.stdout.fileno(),
                                                    sys.stderr.fileno())

    logfile_name = getattr(options, 'logfile', None)
    lockfile_name = getattr(options, 'lockfile', None)

    try:
        if logfile_name is not None:
            global _Logfile
            _Logfile = ewrap(open, logfile_name, 'a', action='append to')
        if lockfile_name is not None: lock = get_lock(lockfile_name)
        func(options, *args)
        if lockfile_name is not None: release_lock(lock)
    except FatalError, why:
        if options.pass_errors:
            raise
        if dup_fatals_to_stdout:
            chat("Fatal error: %s" % why)
        sys.exit("%s: %s" % (sys.argv[0], why))

class _HelptextFormatter (optparse.IndentedHelpFormatter):
    def format_description(self, description):
        return description

def run_script(add_options, func, argspec='',
               nargs=None, help_preamble=None, default_logpath=None,
               default_lockfile=None):
    usage = '%prog [options]' + (' %s' % argspec if argspec else '')
    parser = optparse.OptionParser(usage=usage, description=help_preamble,
                                   formatter=_HelptextFormatter())
    post_option_func = add_options(parser) if add_options else None
    _add_script_options(parser, default_logpath, default_lockfile)
    options, args = parser.parse_args()
    if nargs is None:
        min_args = max_args = len(argspec.split())
    elif isinstance(nargs, int):
        min_args = max_args = nargs
    else:
        min_args, max_args = nargs
    argc = len(args)
    if argc < min_args or (max_args is not None and argc > max_args):
        sys.exit(parser.get_usage() + 'Use --help to show options')
    if post_option_func:
        post_option_func(options)
    try:
        run_with_options(func, options, *args)
    except UsageError, why:
        message = str(why)
        parser.error(message) if message else parser.print_help()

_Known_kwds = set('efmt cant error action exc filename what nofmt'.split())
def ewrap(func, *args, **kwds):
    bad_kwd = set(kwds) - _Known_kwds
    assert not bad_kwd, "Unknown ewrap() keywords: %s" % list_to_phrase(bad_kwd)

    try:
        return func(*args)
    except EnvironmentError, why:
        efmt = kwds.get('efmt')
        if not efmt:
            if kwds.get('cant'):
                efmt = "Can't " + kwds.get('cant')
            elif kwds.get('error'):
                efmt = "Error " + kwds.get('error')
            else:
                action = kwds.get('action', func.__name__)
                what = kwds.get('what')
                efmt = "Can't %s %s%%s" % (action, what + ' ' if what else '')
        if kwds.get('nofmt'):
            mesg = '%s: %s' % (efmt, why.strerror)
        else:
            if '%s' not in efmt:
                efmt += ' %s'
            mesg = (efmt + ': %s') % (kwds.get('filename', why.filename),
                                      why.strerror)
        exc = kwds.get('exc') or FatalError
        raise exc(mesg)

def _maybe_sleep(envvar_name):
    sleep_time = os.environ.get(envvar_name)
    if sleep_time is not None:
        sys.stderr.write("Sleeping lock for %ss [%s] ... " %
                         (sleep_time, envvar_name))
        time.sleep(float(sleep_time))
        sys.stderr.write("done\n")

def _get_lock_with_wait(lfile, timeout, exc):
    def catch_sigalrm(unused_signum, unused_frame):
        raise exc("Can't get exclusive lock on %s: lock busy" % lfile.name)

    old_handler = signal.signal(signal.SIGALRM, catch_sigalrm)
    assert old_handler is signal.SIG_DFL, \
           "Found SIGALRM handler already installed: %r" % old_handler

    old_alarm = signal.alarm(timeout)
    assert old_alarm == 0, "Found alarm() already running"

    try:
        ewrap(fcntl.flock, lfile, fcntl.LOCK_EX,
              cant='get exclusive lock on', filename=lfile.name, exc=exc)
    finally:
        signal.alarm(0)
        signal.signal(signal.SIGALRM, signal.SIG_DFL)

def get_lock(lock_path, exc=None, timeout=5):
    if exc is None:
        exc = FatalError
    lfile = ewrap(open, lock_path, 'r+', what='lock file', exc=exc)

    # Make sure the lock file is closed on exec (don't want any child
    # processes hanging onto it).
    old = ewrap(fcntl.fcntl, lfile, fcntl.F_GETFD,
                action='get fd flags for', filename=lock_path)
    ewrap(fcntl.fcntl, lfile, fcntl.F_SETFD, old | fcntl.FD_CLOEXEC,
          action='set fd flags for', filename=lock_path)

    # Try optimistic non-blocking lock first
    try:
        fcntl.flock(lfile, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except EnvironmentError, why:
        if timeout != 0:
            _get_lock_with_wait(lfile, timeout, exc)
        else:
            raise exc("Can't get exclusive lock on %s: %s" %
                      (lock_path, why.strerror));

    return lfile

def release_lock(lfile):
    fcntl.flock(lfile, fcntl.LOCK_UN)
    lfile.close()

def file_is_locked(path):
    lfile = ewrap(open, path, 'r', what='lock file')
    try:
        fcntl.flock(lfile, fcntl.LOCK_EX | fcntl.LOCK_NB)
        return False
    except EnvironmentError, why:
        if why.errno == errno.EAGAIN:
            return True
        fatal("Can't lock %s: %s" % (path, why.strerror))
    finally:
        ewrap(lfile.close, filename=path)

def with_lock(lock_path, func, exc=None, timeout=5):
    lfile = get_lock(lock_path, exc, timeout)

    try:
        _maybe_sleep('DEBUG_SLEEP_BEFORE_LOCK')
        func()
        _maybe_sleep('DEBUG_SLEEP_AFTER_LOCK')
    finally:
        release_lock(lfile)
