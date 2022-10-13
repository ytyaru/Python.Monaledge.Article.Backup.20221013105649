from db import Db
import importlib
MonaledgeApi = importlib.import_module("monaledge-api")
MonaledgeDb = importlib.import_module("monaledge-db")
import os
# ビジネスロジック。モナレッジAPIから最新取得しDB挿入・更新する。
class Backup:
    def __init__(self):
        self._api = MonaledgeApi.MonaledgeApi()
        self._db = MonaledgeDb.MonaledgeDb()
        self._article_count = -1
    #def __del__(self): self._db.__del__()
    def run(self, address='MEHCqJbgiNERCH3bRAtNSSD9uxPViEX1nu'):
        user = self._api.my_info(address)
        self._db.upsert_user(user)
        self.paginate(user['id'])
    def paginate(self, author_id, page=1):
        articles = self._api.my_articles(author_id, page)
        for article in articles['articles']:
            print(f"---- {article['id']} -----")
            self.upsert_article(article)
        if 1 == page: self._article_count = articles['articlesCount']
        self._article_count -= len(articles['articles'])
        if 0 < self._article_count: self.paginate(author_id, page+1)
        self._db.commit()
    def upsert_article(self, article):
        id = article['id']
        is_get_content = self._db.is_get_content(article)
        method = self._db.insert_article
        if self._db.exists_article(id):
            if not self._db.is_changed_updated(article): return
            method = self._db.update_article if is_get_content else self._db.update_article_header
            #method = self._db.update_article if self._db.is_get_content(article) else self._db.update_article_header
        method(article, self._api.article(id) if is_get_content else None)
    """
    def upsert_article(self, article):
        id = article['id']
        is_get_content = True
        method = self._db.insert_article
        if self._db.exists_article(id):
            if not self._db.is_changed_updated(article): return
            is_get_content = self._db.is_changed_content(article)
            method = self._db.update_article if is_get_content else self._db.update_article_header
        method(article, self._api.article(id) if is_get_content else None)
    """
