#!/usr/local/ntt/bin/python2.5-or-2.6

import optparse, sys, os, commands, re
from nexus.xml import xmlrpc
from pprint import pprint


class SABException (Exception):
    pass

ADMINCMD_PATH = '/usr/bin/sudo /usr/openv/netbackup/bin/admincmd'

# Put in this dict all the policy vars we want to record and what to call them
POLICY_TAG_MAP = {
    'Policy Name'       : 'policy_name',
    'Policy Type'       : 'type',
    'Policy Priority'   : 'priority',
    'Max Jobs/Policy'   : 'max_jobs',
    'Active'            : 'active',
    'Effective date'    : 'effective_date',
    'Client Compress'   : 'client_compress',
    'Follow NFS Mnts'   : 'follow_nfs',
    'Cross Mnt Points'  : 'cross_mounts',
    'Collect TIR info'  : 'collect_tir',
    'Collect BMR Info'  : 'collect_bmr',
    'Block Incremental' : 'block_incremental',
    'Mult. Data Stream' : 'mult_data',
    'Residence'         : 'residence',
    'Volume Pool'       : 'pool',
}

SCHEDULE_TAG_MAP = {
    'Type'              : 'type',
    'Frequency'         : 'frequency',
    'Maximum MPX'       : 'maximum_mpx',
    'Retention Level'   : 'retention_level',
}


def int_or_default(value, default):
    if value == '':
        return default
    return int(value)

def str_or_default(value, default):
    if value == '':
        return default
    return str(value)

def run_command(cmd, expect_output=False):
    (status, output) = commands.getstatusoutput(cmd)

    if (status != 0):
        raise SABException('Error running command: %s\n%s' % (cmd, output))

    if expect_output and len(output) == 0:
        raise SABException('No output from command: %s\n' % cmd)

    return output

def sanitize_vals(val):
    if val == 'yes'                         : return 1
    if val == 'yes, with move detection'    : return 1
    if val == 'no'                          : return 0
    if val == '(none defined)'              : return ''

    return val


# Sab Functions


def sab_get_policy_information():
    cmd = '%s/bppllist -allpolicies -L' % ADMINCMD_PATH
    output = run_command(cmd, expect_output=True)

    policies = []
    var_re = re.compile(r'(\S.*?):\s*(.*)')
    sch_re = re.compile(r'\s\s(\S.*?):\s*(.*)')
    day_re = re.compile(r'\s{3}(\S+)\s+(\d+:\d+:\d+)\s+(\d+:\d+:\d+)')

    empty_policy = lambda: { 'clients' : [], 'schedules' : [], 'include' : [],
                             'exclude' : [] }
    this_policy = empty_policy()

    empty_schedule = lambda: { 'days' : [] }
    this_schedule = empty_schedule()

    seen_policy = False
    added_policy = True
    in_schedule = False

    for line in output.splitlines():
        if line == '':
            if seen_policy:
                if in_schedule:
                    this_policy['schedules'].append(this_schedule)
                policies.append(this_policy)
                this_policy = empty_policy()
                this_schedule = empty_schedule()
                added_policy = True
                in_schedule = False
            continue

        if in_schedule:
            sch = sch_re.match(line)

            if sch is not None:
                (tag, val) = sch.group(1, 2);

                if tag in SCHEDULE_TAG_MAP:
                    this_schedule[SCHEDULE_TAG_MAP[tag]] = val

                continue

            # Check for the daily window lines inside the schedule section

            daily = day_re.match(line)

            if daily is not None:
                (day, start, end) = daily.group(1, 2, 3)

                this_schedule['days'].append({ 'day' : day, 'start' : start,
                                               'end' : end })

        # Wasn't a schedule line so see if it's a var line

        var = var_re.match(line)
        if var is None:
            continue # Temp while were not coping with Day Open ...

        (tag, val) = var.group(1, 2);

        if tag in POLICY_TAG_MAP:
            this_policy[POLICY_TAG_MAP[tag]] = sanitize_vals(val)
            seen_policy = True
            added_policy = False

        if tag == 'Include':
            this_policy['include'].append(val)

        if tag == 'Exclude':
            this_policy['exclude'].append(val)

        if (re.match('Client/HW/OS/Pri', str(tag))):
            (client, hw, os, pri) = val.split(' ', 3)
            this_policy['clients'].append({ 'client' : client, 'os' : os,
                                            'hw' : hw })

        if tag == 'Schedule':
            if in_schedule: # Already in a schedule, so store it
                this_policy['schedules'].append(this_schedule)
                this_schedule = empty_schedule()

            in_schedule = True
            this_schedule['name'] = val

    if in_schedule:
        this_policy['schedules'].append(this_schedule)

    if not added_policy:
        policies.append(this_policy)

    return policies

def parse_all_jobs():
    cmd = '%s/bpdbjobs -report -most_columns' % ADMINCMD_PATH
    output = run_command(cmd, expect_output=True)

    jobs = []

    for line in output.splitlines():
        fields = line.split(',')

        number      = int(fields[0])

        try:
            job_type = int(fields[1])
        except ValueError:
            continue

        if job_type != 0: continue      # Backup Job Type

        state       = int(fields[2])
        exit_code   = fields[3]
        policy      = fields[4]
        schedule    = fields[5]
        client      = fields[6]
        server      = fields[7]
        start_time  = int(fields[8])
        end_time    = int(fields[10])
        kbytes      = str(int_or_default(fields[14], 0))
        file_count  = int_or_default(fields[15], 0)
        percent     = fields[17]
        parent_job  = int_or_default(fields[33], 0)

        job = {
            'number'      : number,
            'job_type'    : job_type,
            'state'       : state,
            'exit_code'   : exit_code,
            'policy'      : policy,
            'schedule'    : schedule,
            'client'      : client,
            'server'      : server,
            'start_time'  : start_time,
            'end_time'    : end_time,
            'kbytes'      : kbytes,
            'file_count'  : file_count,
            'percent'     : percent,
            'parent_job'  : parent_job,
        }

        jobs.append(job)

    return jobs

def sab_get_job_information():
    cmd = '%s/bpdbjobs -report -most_columns' % ADMINCMD_PATH
    output = run_command(cmd, expect_output=True)

    jobs = []

    for line in output.splitlines():
        fields = line.split(',')

        number      = int(fields[0])

        try:
            job_type = int(fields[1])
        except ValueError:
            continue

        state       = int(fields[2])
        exit_code   = fields[3]
        policy      = str_or_default(fields[4], '-')
        schedule    = str_or_default(fields[5], '-')
        client      = fields[6]
        server      = fields[7]
        start_time  = int(fields[8])
        end_time    = int(fields[10])
        kbytes      = str(int_or_default(fields[14], 0))
        file_count  = int_or_default(fields[15], 0)
        percent     = fields[17]

        job = {
            'number'      : number,
            'job_type'    : job_type,
            'state'       : state,
            'exit_code'   : exit_code,
            'policy'      : policy,
            'schedule'    : schedule,
            'client'      : client,
            'server'      : server,
            'start_time'  : start_time,
            'end_time'    : end_time,
            'kbytes'      : kbytes,
            'file_count'  : file_count,
            'percent'     : percent,
        }

        jobs.append(job)

    return jobs

def sab_get_job_trylogs(job_id):
    cmd = '%s/bpdbjobs -jobid %d -all_columns' % (ADMINCMD_PATH, job_id)
    output = run_command(cmd, expect_output=False)

    if len(output) == 0:
        return []

    output = output.replace('\\\\', '__BACKSLASH__')
    output = output.replace('\\,', '__COMMA__')
    output = output.replace('__BACKSLASH__', '\\')
    fields = output.split(',')

    number = int(fields[0])
    if number != job_id:
        return []

    file_count = int(fields[31])
    try_count  = int(fields[32 + file_count])

    list_offset = 33 + file_count

    trys = []

    for try_index in range(try_count):
        try_start      = int(fields[list_offset+3])
        try_duration   = int(fields[list_offset+4])
        try_end        = fields[list_offset+5]
        try_exit       = fields[list_offset+6]
        try_line_count = int(fields[list_offset+8])
        try_kbytes     = fields[list_offset + 9 + try_line_count]
        try_files      = fields[list_offset + 10 + try_line_count]

        try_lines = []
        for line_index in range(list_offset + 9,
                                list_offset + 9 + try_line_count):
            try_lines.append(fields[line_index].replace('__COMMA__', ','))

        this_try = {
            'start'     : try_start,
            'duration'  : try_duration,
            'end'       : try_end,
            'exit_code' : try_exit,
            'kbytes'    : try_kbytes,
            'files'     : try_files,
            'lines'     : try_lines
        }

        trys.append(this_try)

        list_offset += 11 + try_line_count

    return trys


class RequestHandler (xmlrpc.RequestHandler):

    @xmlrpc.handler(dict())
    def get_policy_information(self):
        """Get information for all backup policies"""
        return sab_get_policy_information()

    # Need to remove this one as it will be replaced with get_job_information
    @xmlrpc.handler(dict())
    def get_all_jobs(self):
        """Get information for backup jobs"""
        return parse_all_jobs()

    @xmlrpc.handler(dict())
    def get_job_information(self):
        """Get information for all backup jobs"""
        return sab_get_job_information()

    @xmlrpc.handler(dict(job_id='int'))
    def get_job_trylogs(self, job_id):
        """Get trylogs for failed backup jobs"""
        return sab_get_job_trylogs(job_id)


def test(request_handler):
    res = request_handler.get_job_trylogs(917191)
    pprint(res)

def get_optvals():
    parser = optparse.OptionParser(usage='%prog [options]')

    parser.add_option('--test', action='store_true', default=False,
                      help='Run the test functions, not server requests')

    xmlrpc.add_cmdline_options(parser)

    (optvals, args) = parser.parse_args()

    if len(args) > 0:
        sys.exit(parser.get_usage() + 'Use --help to show options')

    return optvals

def main():
    server_help = "Gather info from netbackup policies and jobs"
    optvals = get_optvals()
    request_handler = RequestHandler()

    if optvals.test:
        test(request_handler)
    else:
        xmlrpc.handle_requests(request_handler, server_help, optvals)


if __name__ == '__main__':
  main()
