import json
import urllib3
from twisted.internet import task, reactor
import socket

timeout = 10.0 # Ten seconds

statsdHost = "127.0.0.1"
statsdPort = 8125

environments = json.loads('[{ "name" : "badgersktlocal", "hostname" : "127.0.0.1", "port": 8082 }]')

http = urllib3.PoolManager()

def collect():
  for env in environments:
    url = "http://%s:%d/metrics" %(env["hostname"], env["port"])
    try:
      response = http.request('GET', url, timeout=5)
      data = json.loads(response.data)
      for gauge in data["gauges"]:
        gauge_value = data["gauges"][gauge]["value"]
        s = "%s.%s:%s|g" %(env["name"], gauge, gauge_value)
        netcat(s)
      for timer in data["timers"]:
        count = data["timers"][timer]["count"]
        s = "%s.timers.%s.count:%s|g" %(env["name"], timer, count)
        netcat(s)
        mean = data["timers"][timer]["mean"]
        s2 = "%s.timers.%s.mean:%s|g" %(env["name"], timer, mean)
        netcat(s2)
    except Exception as e:
      print("An exception occurred processing %s:" %(env["name"]))
      print(e)

def netcat(content):
  sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
  sock.connect((statsdHost, statsdPort))
  sock.sendall(content)
  sock.shutdown(socket.SHUT_WR)
  sock.close()

l = task.LoopingCall(collect)
l.start(timeout) # call every n seconds

reactor.run()