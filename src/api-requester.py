#!/usr/bin/env python3
# coding: utf8
import urllib.request
import json
import time
class ApiRequester:
    def __init__(self): self._sleep_time = 1
    def get(self, url, data=None): return self._request('GET', url, data)
    def post(self, url, data): return self._request('POST', url, data)
    def put(self, url, data): return self._request('PUT', url, data)
    def patch(self, url, data): return self._request('PATCH', url, data)
    def delete(self, url, data): return self._request('DELETE', url, data)
    def _request(self, method, url, data):
        print(method, url)
        print(data)
        req = urllib.request.Request(self._url(method, url, data), json.dumps(data).encode(), self._headers(), method=method)
        with urllib.request.urlopen(req) as res:
            time.sleep(self._sleep_time)
            return json.loads(res.read().decode('utf-8'))
    def _headers(self): return { 'Content-Type': 'application/json' }
    def _url(self, method, url, data):
        if data is None: return url
        match method:
            case 'GET': return '{}?{}'.format(url, urllib.parse.urlencode(data))
            case _: return url
