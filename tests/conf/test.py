#!/usr/bin/python
import logging
import requests
import time
import os

#TEST_ADDRESS = the DOcker container DNS name:port combo of our Varnish container
TEST_ADDRESS = os.getenv('TEST_ADDRESS',0)

def testWebBackend(url):
  LOG_FILENAME = 'example.log'
  logging.basicConfig(filename=LOG_FILENAME,level=logging.DEBUG)
  logging.debug("Running test on "+str(url))
  try:
    res = requests.get(url)
  except:
    logging.debug("FAILURE to call GET")
    return
  if res.status_code == 200:
    logging.debug("SUCCESS")
  else:
    logging.debug("FAILURE on non 200 return")
    logging.debug( res.text )

testWebBackend("http://google.com")
testWebBackend("http://yahoofffed.com")
testWebBackend(TEST_ADDRESS)

time.sleep(1000) #sleep to keep container open for verification
