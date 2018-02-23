#!/usr/bin/python -OO
#
# Copyright 2018 The SynoCommunity team
#
# This script is called by the Makefile

import sys
import json
import urllib2

# Travis URL
TRAVIS_URL = 'https://api.travis-ci.org/repo/Safihre%2Fspksrc/requests'

# Parse arguments
try:
    spk = sys.argv[1]
    travis_api = sys.argv[2]
    archs = sys.argv[3:]
except:
    print "Could not understand input!"
    sys.exit(1)

# Build basic header
header = {}
header["Content-Type"] = "application/json"
header["Accept"] = "application/json"
header["Travis-API-Version"] = "3"
header["Authorization"] = "token %s" % travis_api

# Build body of the request
request_body = {}
request_body["request"] = {}
request_body["request"]["branch"] = "ci-setup"
request_body["request"]["message"] = "Request build of %s" % spk
request_body["request"]["config"] = {}
request_body["request"]["config"]["merge_mode"] = "deep_merge"
request_body["request"]["config"]["env"] = {}

# Set package
request_body["request"]["config"]["env"]["global"] = ["PKG=%s" % spk]

# Add the archs
request_body["request"]["config"]["env"]["matrix"] = []
for arch in archs:
    request_body["request"]["config"]["env"]["matrix"].append('SYNOARCH=%s' % arch)

# Do the request
travis_req = urllib2.Request(TRAVIS_URL, json.dumps(request_body), header)
response_json = urllib2.urlopen(travis_req).read()

# Parse output
response = json.loads(response_json)

# All good?
if response["@type"] and response["@type"] == "pending":
    print "Request to Travis successful!"
    print "Package: %s" % spk
    print "Archs: %s" % ' '.join(archs)
else:
    print "Possible problem with request, inspect response!"
    print response
    sys.exit(1)
