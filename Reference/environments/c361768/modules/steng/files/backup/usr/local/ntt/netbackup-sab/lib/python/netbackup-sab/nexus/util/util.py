class Obj:
    def copy(self):
        object = Obj()
        object.__dict__.update(self.__dict__)
        return object

def obj(**args):
    object = Obj()
    object.__dict__.update(args)
    return object

def rows_to_dict(key, rows):
    new_dict = {}
    for row in rows:
        key_val = row[key]
        new_dict[key_val] = row
    return new_dict

def plural(count, what):
    return '%d %s%s' % (count, what, ('' if count == 1 else 's'))

def list_to_phrase(seq, conj='and'):
    if isinstance(seq, dict):
        vals = sorted(seq.keys())
    elif isinstance(seq, set):
        vals = sorted(seq)
    else:
        vals = seq

    if len(seq) == 1:
        return vals[0]
    else:
        return "%s %s %s" % (", ".join(vals[:-1]), conj, vals[-1])
