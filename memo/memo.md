モナレッジで書いた自分の記事をバックアップする4【python】

　タイトルが更新されたときは必ず本文やコメントも更新するようにした。

<!-- more -->

# ブツ

* [リポジトリ][]

[リポジトリ]:https://github.com/ytyaru/Python.Monaledge.Article.Backup.20221013105649

# 実行

```sh
ADDRESS='モナレッジに登録した自分のモナコイン用アドレス'
NAME='Python.Monaledge.Article.Backup.20221013105649'
git clone https://github.com/ytyaru/$NAME
cd $NAME/src
./run.py $ADDRESS
./file.sh
```

# 結果

　`monaledge.db`というSQLite3ファイルに保存される。

　`file.sh`で記事ひとつずつをマークダウンファイルとして出力する。

## DB更新ルーティング

処理|条件
----|----
挿入する|APIで取得した記事IDがDBに存在しない
更新する（本文・コメント含め）|タイトルがDBの値と異なる。または更新日時が違うのに他のヘッダ項目が同一である。
更新する（ヘッダ項目のみ）|ヘッダ項目がDBの値と異なる
何もしない|更新日時が変わっていない

　[モナレッジAPIを調査する][]にあるとおり`myArticles`で10件ずつ記事を取得する。そして`article`で個別に本文とコメントを取得する。`article`を発行すると副作用としてアクセス数や更新日時が変わってしまう。できるだけ呼び出さぬよう、かつ本文やコメントの更新漏れをできるなけ少なくするような判定アルゴリズムにした。

　特筆すべきは運用による工夫でそれを実現している所。タイトル更新されたら本文が更新されたと判断するようにしている。たとえば「（記事名）追記」や「（記事名）改稿」といったように本文の改稿とあわせてタイトルも変更する。これにより本バックアップツールでは`myArticles`で取得したタイトルがDBのそれと異なることで本文も改稿されたと判断し、`article`で本文やコメントを取得し更新する。

　もしタイトルを更新せず本文だけ更新した場合、更新日時以外のヘッダ項目に変化がなければ更新される。だが、もしアクセス数など他のヘッダ項目に変化があればヘッダ項目だけ更新され、本文やコメントは更新されない。なので確実に本文を更新したいときは本文と一緒にタイトルも変更するようにする。

[モナレッジAPIを調査する]:

# コード抜粋

## 変更判定

### backup.py

```python
def upsert_article(self, article):
    id = article['id']
    is_get_content = self._db.is_get_content(article)
    method = self._db.insert_article
    if self._db.exists_article(id):
        if not self._db.is_changed_updated(article): return
        method = self._db.update_article if is_get_content else self._db.update_article_header
    method(article, self._api.article(id) if is_get_content else None)
```

### monaledge-db.py

```python
def exists_article(self, id): return self._exiest_record('articles', id)
def get_article(self, id): return self.exec(f"select * from articles where id = {id};").fetchone()
def get_article_updated(self, id): return self.get_article(id)[2]
def is_changed_updated(self, header): return self.get_article_updated(header['id']) < header['updatedAt']
def is_get_content(self, header):
    if not self.exists_article(header['id']): return True
    record = self.get_article(header['id'])
    ans = self.is_changed_content_only(header, record)
    return ans if ans else self.is_changed_title(header, record)
def is_changed_content_only(self, header, record):
    # 本文更新判定（article APIを叩かずmyArticlesの結果だけで判定したい）
    return record[2] < header['updatedAt'] and \
            header['title'] == record[3] and \
            header['sent_mona'] == record[4] and \
            header['access'] == record[5] and \
            header['ogp_path'] == record[6] and \
            header['category'] == record[7]
def is_changed_title(self, header, record):
    return not header['title'] == record[3]
```

# 所感

　ビジネスロジックはこれで大体OK。本当は複数のアドレスで実行できてしまいDBが破綻してしまう点が気になるけど。まあ自分のアドレスだけ与えて実行すればいいだけだし。べつにいいか。

　あとはリファクタリングかな。`monaledge-db.py`がだいぶ汚い。

