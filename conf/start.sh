#!/bin/sh

echo "starting varnishd" > ./start.log

# The -a  tells Varnish what port to listen on
varnishd -s malloc,${VARNISH_MEMORY} -a :6081 -f /etc/varnish/default.vcl

retrys=0
until varnishtop -1; 
do
  sleep 1
  echo "waiting for varnish to initialize retry count $retrys" >> ./start.log

  let "retrys++"

  if [ "$retrys" -gt 10 ]; then
    break
  fi
done

if varnishtop -1; then
  echo "varnish started" >> ./start.log

  echo "starting varnish log with arguments: $VARNISHLOG_ARGS" >> ./start.log

  # In order to support special characters (like quotes) in VARNISHLOG_ARGS we need to create space delimited array
  ARGS_ARRAY=($VARNISHLOG_ARGS)
  
  # Eval must be used when dereferencing the array
  eval varnishlog "${ARGS_ARRAY[@]}"

else
  echo "Varnish failed to start" >> ./start.log
fi
