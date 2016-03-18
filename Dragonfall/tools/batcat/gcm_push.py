# -*- coding: utf-8 -*-
import requests
import sys
import getopt

send_url = 'https://android.googleapis.com/gcm/send'
api_key = 'AIzaSyDLIZhTJy9UIwBp78jfqIoWnb1DtmYMINw'
msg = "This is a GCM Topic Message!"
register_id = ""

if __name__ == "__main__":
    try:
        opts, args = getopt.getopt(sys.argv[1:], 'k:m:i', [
                                   'key=', 'message=', 'id='])
        for opt, arg in opts:
            if opt in ('-k', "--output"):
                api_key = arg
            elif opt in ('-i', "--id"):
                register_id = arg
            elif opt in ('-m', "--message"):
                msg = arg
    except getopt.GetoptError:
        sys.exit(1)

headers = {'Authorization': 'key=' + api_key,
           'Content-Type': 'application/json'}
msg = '{"registration_ids" : ["%s"],"data": {"message": "%s"}}' % (
    register_id, msg)
r = requests.post(send_url, data=msg, headers=headers)
print("------- google gcm send result -------\n%s" % r.text)
