#!/usr/bin/env python3
# coding: utf8
import importlib
ApiRequester = importlib.import_module("api-requester")
import urllib.parse

class MonaledgeApi:
    def __init__(self):
        self._base = 'https://monaledge.com:8443'
        self._req = ApiRequester.ApiRequester()
    def my_info(self, address):
        return self._req.post(self._url('myInfo'), {'address':address})
    def my_articles(self, author_id, page=1):
        return self._req.post(self._url('myArticles'), {'author_id':author_id, 'page':page})
    def article(self, id):
        return self._req.get(self._url('article'), {'id':id})
    def _url(self, path): return urllib.parse.urljoin(self._base, path)
        

