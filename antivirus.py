#!/usr/bin/python3

import cgi
import subprocess
import sys

CGI_FORM_FILETOCHECK = 'filetocheck'

print("Content-Type: text/plain; charset=UTF-8")
print()

form = cgi.FieldStorage()
fileitem = form[CGI_FORM_FILETOCHECK] if CGI_FORM_FILETOCHECK in form else None
if fileitem is not None and fileitem.file is not None:
    realfilename = fileitem.filename

    p = subprocess.Popen('/usr/bin/clamdscan --verbose --stdout --multiscan --fdpass -'.split(),
                         stderr=subprocess.STDOUT,
                         stdout=subprocess.PIPE,
                         stdin=subprocess.PIPE,
                         bufsize=8192)
    stdout, stderr = p.communicate(input=fileitem.file.read())
    sys.stdout.flush()
    print(stdout.decode("utf-8"))
    rv = p.wait()

    print("------------------------------------")
    print("clamscan exit code: %s" % rv)
    print("real filename was: %s" % realfilename)
    print("__AVSTATUS__= %s " % ("OK" if rv == 0 else "VIRUS" if rv == 1 else "FAIL"))
else:
    print("Invalid request - try /avform for testing antivirus")
    raise Exception("CGI mode assumed, but no form field 'filetocheck' present")
