#!/usr/bin/python

import cgi
import os
import subprocess
import sys
import tempfile

import argparse

parser = argparse.ArgumentParser(description='Scan input for virus using clamav')
parser.add_argument("fromfile", nargs='?', help='Scan a local file, if positional argument is not present, assume CGI')
args = parser.parse_args()

CGI_FORM_FILETOCHECK='filetocheck'

iscgi = False
if not args.fromfile:
    print "Content-Type: text/plain; charset=UTF-8"
    print

    iscgi = True
    form = cgi.FieldStorage()

    fileitem = form[CGI_FORM_FILETOCHECK] if form.has_key(CGI_FORM_FILETOCHECK) else None
    if fileitem is not None and fileitem.file is not None:
        tmpfile = tempfile.NamedTemporaryFile(delete=False)
        tmpfile.write(fileitem.file.read())
        tmpfile.close()
        # os.fchmod(tmpfile, 644)
        filetocheck = tmpfile.name
        realfilename=fileitem.filename
    else:
	print "Invalid request - try /avform for testing antivirus"
        raise Exception("CGI mode assumed, but no form field 'filetocheck' present")

else:
    filetocheck = args.fromfile
    realfilename = filetocheck

p = subprocess.Popen('/usr/bin/clamdscan --verbose --stdout --multiscan --fdpass'.split() + [filetocheck],
                     stderr=subprocess.STDOUT,
                     stdout=subprocess.PIPE,
                     bufsize=8192,
                     env={"HOME": "/tmp"})

sys.stdout.flush()
sys.stdout.write(p.stdout.read())
rv=p.wait()

print "------------------------------------"
print "clamscan exit code: %s" % rv
print "real filename was: %s" % realfilename
print "__AVSTATUS__= %s " % ("OK" if rv == 0 else "VIRUS" if rv == 1 else "FAIL")

if iscgi:
    os.remove(filetocheck)
