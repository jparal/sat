# -*- coding: utf-8 -*-
# Pretty-printers for SAT.

import gdb
import itertools
import re

class String:
    "Pretty Printer for String"

    def __init__(self, val):
        self.val = val

    def to_string(self):

        data = self.val['Data']
        mini = self.val['minibuff']

        if data != 0:
            return "%s" % (data)
        else:
            return "%s" % (mini)

def register_sat_printers (obj):
    if obj == None:
        obj = gdb

    obj.pretty_printers.append (lookup_function)

def lookup_function (val):
    "Look-up and return a pretty-printer that can print val."

    # Get the type.
    type = val.type;

    # If it points to a reference, get the reference.
    if type.code == gdb.TYPE_CODE_REF:
        type = type.target ()

    # Get the unqualified type, stripped of typedefs.
    type = type.unqualified ().strip_typedefs ()

    # Get the type name.
    typename = type.tag
    if typename == None:
        return None

    # Iterate over local dictionary of types to determine
    # if a printer is registered for that type.  Return an
    # instantiation of the printer if found.
    for function in pretty_printers_dict:
        if function.search (typename):
            return pretty_printers_dict[function] (val)

    # Cannot find a pretty printer.  Return None.
    return None

def build_dictionary ():
    pretty_printers_dict[re.compile('^String$')] = lambda val: String(val)

pretty_printers_dict = {}

build_dictionary ()
