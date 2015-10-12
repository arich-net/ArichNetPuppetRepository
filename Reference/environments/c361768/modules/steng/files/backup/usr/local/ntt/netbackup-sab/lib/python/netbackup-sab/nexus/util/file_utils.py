from contextlib import contextmanager
import os, fcntl, sys, time, signal, errno, datetime, hashlib, filecmp
from .util import list_to_phrase
from .script_utils import ewrap, fatal, FatalError

def current_time_filetag():
    tag = datetime.datetime.utcnow().isoformat()
    return tag if '.' in tag else tag + '.000000'

def fdcopy_with_sha256_checksum(src_fd, src_path, dst_fd, dst_path):
    hash = hashlib.sha256()
    while True:
        buf = ewrap(os.read, src_fd, 64 * 1024,
                    error='reading', filename=src_path)
        if not buf:
            break
        hash.update(buf)
        ewrap(os.write, dst_fd, buf, error='writing to', filename=dst_path)
    return hash.hexdigest()

def get_file_sha256_checksum(path):
    fd = ewrap(os.open, path, os.O_RDONLY, cant='open %s for reading')
    hash = hashlib.sha256()
    try:
        while True:
            buf = ewrap(os.read, fd, 64 * 1024, error='reading', filename=path)
            if not buf:
                break
            hash.update(buf)
    except FatalError:
        os.close(fd)
        raise
    ewrap(os.close, fd, error='closing', filename=path)
    return hash.hexdigest()

def copy_with_sha256_checksum(src_path, dst_path):
    src_fd = ewrap(os.open, src_path, os.O_RDONLY, cant='open %s for reading')
    try:
        dst_fd = ewrap(
            os.open, dst_path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0666,
            cant='create file %s')
    except FatalError:
        os.close(src_fd)
        raise

    try:
        hexdigest = fdcopy_with_sha256_checksum(
            src_fd, src_path, dst_fd, dst_path)
    except FatalError:
        os.close(src_fd)
        os.close(dst_fd)
        raise

    ewrap(os.close, src_fd, error='closing', filename=src_path)
    ewrap(os.close, dst_fd, error='closing', filename=dst_path)
    return hexdigest

def rename_file(oldpath, newpath, exc=None, what='file'):
    ewrap(os.rename, oldpath, newpath, exc=exc,
          cant='rename %s %s to %s' % (what, oldpath, newpath), nofmt=True)

def _want_new_version(oldpath, newpath):
    return not(os.path.exists(oldpath) and
               filecmp.cmp(oldpath, newpath, shallow=False))

@contextmanager
def replace_file_contents(path, exc=None):
    if exc is None:
        exc = FatalError
    tmp_path = path + '.tmp-%d' % os.getpid()
    ofile = ewrap(open, tmp_path, 'a', what='temporary file', exc=exc)
    keep_tmp_file = False
    try:
        yield ofile
        ofile.close()
        keep_tmp_file = _want_new_version(path, tmp_path)
    except EnvironmentError, why:
        keep_tmp_file = True
        raise exc("Error writing to temporary file %s: %s" %
                  (tmp_path, why.strerror))
    finally:
        if not keep_tmp_file:
            try:
                os.remove(tmp_path)
            except EnvironmentError, why:
                # We're already handling an exception - ignore cleanup errors
                pass
    if keep_tmp_file:
        rename_file(tmp_path, path, exc=exc)

def check_dir_exists(dirpath, what):
    if not os.path.exists(dirpath):
        fatal("%s directory %s does not exist" % (what, dirpath))
    if not os.path.isdir(dirpath):
        fatal("%s path %s is not a directory" % (what, dirpath))

def ensure_subdir_exists(dir_path, subdir_name, mode=0777, what='directory'):
    subdir_path = os.path.join(dir_path, subdir_name)
    if not os.path.exists(subdir_path):
        ewrap(os.mkdir, subdir_path, mode, action='make %s' % what)
    return subdir_path

def get_mtime(path, exc=None):
    return ewrap(os.stat, path, exc=exc).st_mtime

def read_file(path):
    ifile = ewrap(open, path, 'r')
    contents = ewrap(ifile.read)
    ewrap(ifile.close, action='closing', filename=path)
    return contents

def write_file(path, contents):
    ofile = ewrap(open, path, 'w', action='write to')
    ewrap(ofile.write, contents)
    ewrap(ofile.close, error='closing')

def with_umask(new_umask, func, *args):
    old_umask = os.umask(new_umask)
    try:
        func(*args)
    finally:
        os.umask(old_umask)

_Max_fds = None

def get_num_open_fds():
    global _Max_fds
    if _Max_fds is None:
        try:
            _Max_fds = os.sysconf('SC_OPEN_MAX')
        except Exception, why:
            _Max_fds = 1024
            sys.stderr.write(
                "Warning: sysconf failed (%s) - scanning up to %d when "
                "reporting number of currently open fds\n" % (why, _Max_fds))

    nopen = 0
    probe, ebadf = os.fstat, errno.EBADF # Save a little time
    for fd in xrange(_Max_fds):
        try:
            probe(fd)
        except EnvironmentError, why:
            if why.errno != ebadf:
                nopen += 1
        else:
            nopen += 1
    return nopen


class TimestampWrapper (object):
    def __init__(self, ofile):
        self.ofile = ofile
        self.atbol = True

    def write(self, mesg):
        atbol = self.atbol
        lines = mesg.split('\n')
        lastline = lines.pop()      # Guaranteed at least one line from split()
        prefix = '%s UTC %5d: ' % (
            datetime.datetime.utcnow().isoformat(), os.getpid())

        for line in lines:
            self.ofile.write((prefix if atbol else '') + line + '\n')
            atbol = True

        if lastline:
            self.ofile.write((prefix if atbol else '') + lastline)
        self.atbol = not lastline

    def writelines(self, lines):
        for line in lines:
            self.write(line)

    def flush(self):
        self.ofile.flush()

def timestamp_if_not_a_tty(ofile):
    assert not isinstance(ofile, TimestampWrapper), \
           "Double wrapping of %r attempted" % ofile.ofile
    no_timestamps = int(os.environ.get('DEBUG_NO_STDERR_TIMESTAMPS', '0'))
    return ofile if no_timestamps or ofile.isatty() else TimestampWrapper(ofile)

class Logfile (object):
    def __init__(self, path, prefix=None):
        self._path = path
        self._prefix = '' if prefix is None else prefix

    def write(self, message):
        now = str(datetime.datetime.now())[:-7]
        log_line = '%s %s %s' % (now, self._prefix, message)

        f = open(self._path, 'a')
        f.write(log_line + '\n')
        f.close()
