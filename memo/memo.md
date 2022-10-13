モナレッジで書いた自分の記事をバックアップする3【python】

　更新判定を変えた。[myArticles][]で取得できる要素だけで本文またはコメントが更新されているか判定するようにした。

<!-- more -->

# ブツ

* [リポジトリ][]

[リポジトリ]:https://github.com/ytyaru/Python.Monaledge.Article.Backup.20221012161219

# 実行

```sh
ADDRESS='モナレッジに登録した自分のモナコイン用アドレス'
NAME='Python.Monaledge.Article.Backup.20221012161219'
git clone https://github.com/ytyaru/$NAME
cd $NAME/src
./run.py $ADDRESS
./file.sh
```

# 結果

　`monaledge.db`というSQLite3ファイルに保存される。

　`file.sh`で記事ひとつずつをマークダウンファイルとして出力する。

## 前回との差異

* [][]

[]:

　更新判定を変えた。[myArticles][]で取得できる要素だけで本文またはコメントが更新されているか判定するようにした。[article][]を実行する頻度を最小限に抑えつつ、できるだけ更新を取りこぼさないようにできたはず。

　前々回まで問題だったアクセス数インクリメント問題はほぼ解消された。

# コード抜粋

## 変更判定

### backup.py

```python
    def upsert_article(self, article):
        id = article['id']
        is_get_content = True
        method = self._db.insert_article
        if self._db.exists_article(id):
            if not self._db.is_changed_updated(article): return
            is_get_content = self._db.is_changed_content(article)
            method = self._db.update_article if is_get_content else self._db.update_article_header
        method(article, self._api.article(id) if is_get_content else None)
```

　記事とコメントの更新は以下の4ルートに分岐する。

処理|条件
----|----
何もしない|指定した記事IDのレコードが既存なら
挿入する|指定した記事IDのレコードがないなら
更新する（全項目）|レコードが既存かつ本文またはコメントが更新されているなら
更新する（ヘッダ項目のみ）|レコードが既存かつ本文またはコメントが更新されていないなら

　今回のポイントは変更判定。本文またはコメントが更新されているかどうかを`is_changed_content()`で行う。後述するがその内容は以下。更新日時がDBのより新しく、ヘッダ項目（アクセス数、モナ、OGPパス、カテゴリ）に変更がなければ、本文またはコメントが更新されたと判断する。

```python
    def is_changed_content(self, header):
        # 本文更新判定（article APIを叩かずmyArticlesの結果だけで判定したい）
        article = self.get_article(header['id'])
        return article[2] < header['updatedAt'] and \
                header['sent_mona'] == article[4] and \
                header['access'] == article[5] and \
                header['ogp_path'] == article[6] and \
                header['category'] == article[7]
```

　もし本文またはコメントが更新されたと判断されたら[article][] APIを発行して本文やコメントを取得し、それぞれに更新処理をかける。

### monaledge-db.py

```python
    def exists_article(self, id): return self._exiest_record('articles', id)
    def get_article(self, id): return self.exec(f"select * from articles where id = {id};").fetchone()
    def get_article_updated(self, id): return self.get_article(id)[2]
    def is_changed_updated(self, header): return self.get_article_updated(header['id']) < header['updatedAt']
    def is_changed_content(self, header):
        # 本文更新判定（article APIを叩かずmyArticlesの結果だけで判定したい）
        article = self.get_article(header['id'])
        return article[2] < header['updatedAt'] and \
                header['sent_mona'] == article[4] and \
                header['access'] == article[5] and \
                header['ogp_path'] == article[6] and \
                header['category'] == article[7]
    def insert_article(self, article, content):
        print('--- insert ---')
        self.exec("insert into articles values(?,?,?,?,?,?,?,?,?);", (article['id'], article['createdAt'], article['updatedAt'], article['title'], article['sent_mona'], article['access'], article['ogp_path'], article['category'], content))
        self.upsert_comments(article['comments'])
    def update_article(self, article, content):
        print('--- update ---')
        self.exec("update articles set created=?, updated=?, title=?, sent_mona=?, access=?, ogp_path=?, category_id=? content=? where id = ?;", (article['createdAt'], article['updatedAt'], article['title'], article['sent_mona'], article['access'], article['ogp_path'], article['category'], content, article['id']))
        self.upsert_comments(article['comments'])
    def update_article_header(self, article, content=None):
        print('--- update-header ---')
        self.exec("update articles set updated=?, sent_mona=?, access=?, ogp_path=?, category_id=? where id = ?;", (article['updatedAt'], article['sent_mona'], article['access'], article['ogp_path'], article['category'], article['id']))
    def upsert_comments(self, comments):
        self.execm("insert or ignore into comments values(?,?,?,?,?,?);", list(map(lambda c: (c['id'], c['article_id'], c['createdAt'], c['updatedAt'], c['user']['id'], c['comment']), comments)))
```

# 課題

　今回の方法はある場合においてDB更新漏れが起きる。

　たとえばカテゴリと本文を変更したとき「本文に更新なし」と判定されてしまい新しい本文を取得せずDB更新されない。カテゴリが変更された時点で本文またはコメントに更新されたかどうかはわからなくなる。カテゴリやアクセス数などのヘッダ項目が更新されただけかもしれないし、本文またはコメントもあわせて更新されたかもしれない。

　本文またはコメントが更新されたかどうかは[article][] APIでそれらを取得しDBの値と比較する必要がある。でも、[article][] APIを実行した時点でアクセス数や更新日時が変更されてしまう。サーバ負荷もあがる。だから[article][] APIを実行せずに本文またはコメントに更新があったか判定したくて今回のような判定方法にしたという経緯がある。

　かといって、もし本文編集と関わるカテゴリやOGPパスを更新判定から排除したら別の問題が発生する。たとえばカテゴリだけ変更したにも関わらず本文が更新されたと判定されてしまう。それは困るので仕方なく現状に落ち着いた。

選択肢|方法|問題
------|----|----
現状|レコードが既存かつヘッダ項目が同一なら本文またはコメントが更新されたと判断する|ヘッダ項目と本文（またはコメント）の両方が変更されたとき、本文に変更なしと判断されて本文やコメントが更新されない
別案|レコードが既存かつアクセス数とモナが同一なら本文またはコメントが更新されたと判断する|カテゴリまたはOGPパスのいずれかひとつまたは両方だけが更新されただけなのに、本文またはコメントも更新されたと判断されムダに[article][] APIが発行されてしまう

　OGPパスが変更されることはあるのか？　もしあるとすればタイトルが更新されたときだろう。OGP画像の内容はタイトルだから。なら[article][] APIを発行する必要はない。ならOGPパスについては考慮する必要がないか。

　次の内どちらがよりレアケースか。

* ヘッダ項目と本文またはコメントを変更する
* カテゴリだけを変更する

　後者だろう。前者の場合、本文は自分自身で変更する。カテゴリだけ変更するよりも頻度は多いか？　ちょっとわからない。ただ、ヘッダ項目やコメントは自分以外のだれかによって変更される。とくにアクセス数についてはアクセスしただけで変わるので、間違いなく記事やカテゴリの更新よりも高頻度・高確率で起こるだろう。

　だったら、現状より別案のほうがよいのでは？　どちらの方法も問題がある。けど、より問題が起こりにくいレアケースのほうを実装したほうが悪影響を起こしにくいはず。

　それと、起こる問題の強度について。

* DBが更新されない
* 余計な[article][] APIが発行される

　更新されないのはバックアップの目的を達成できず致命的。それに対して余計な[article][] APIが発行されるほうは、それ自体はサーバに負荷がかかるだけ。どちらかというと同APIの副作用が問題。すなわちアクセス数や更新日時が更新されてしまうこと。ただしそれについては「カテゴリ、OGPパス、またはその両方だけ変更する」ときだけ発生する。本文またはコメントも一緒に更新されていたらどのみち[article][] APIを発行せねばならないため。それはもうAPIの仕様なのでどうにもならない。

選択肢|方法|問題|頻度|致命度
------|----|----|----|------
現状|レコードが既存かつヘッダ項目が同一なら本文またはコメントが更新されたと判断する|ヘッダ項目と本文（またはコメント）の両方が変更されたとき、本文に変更なしと判断されて本文やコメントが更新されない|多|大
別案|レコードが既存かつアクセス数とモナが同一なら本文またはコメントが更新されたと判断する|カテゴリまたはOGPパスのいずれかひとつまたは両方だけが更新されただけなのに、本文またはコメントも更新されたと判断されムダに[article][] APIが発行されてしまう|少|微

　ところで、ヘッダ項目としてタイトルが含まれていない。もしタイトルだけを更新したら更新日時が変わるのに他の項目は変わっていないことになる。現状、別案ともに「本文またはコメントが変更された」と判断されてしまいムダに[article][] APIが発行されてしまう。

　さらに問題なのはヘッダ項目と本文（またはコメント）の両方が更新されているとき。現状と別案ではヘッダ項目は更新され、本文とコメントは更新されない。それだと困る。そこでさらなる追加案として、タイトルが変更されているときは本文も更新されたと仮定し、[article][] APIを発行して本文やコメントを取得してDB更新するようにしたい。

　まとめると、更新判定に「タイトルがDBと同じなら」を追加する。さらに[article][] API発行条件に「タイトルが更新されていたら」を追加する。

```python
    def is_get_content(self, header):
        record = self.get_article(header['id'])
        ans = self._db.is_changed_content_only(header, record)
        #if not ans: ans = self._db.is_changed_title(header, record)
        return ans if ans else self._db.is_changed_title(header, record)
    def is_changed_content_only(self, header, record):
        # 本文更新判定（article APIを叩かずmyArticlesの結果だけで判定したい）
        return article[2] < header['updatedAt'] and \
                header['title'] == record[3] and \
                header['sent_mona'] == record[4] and \
                header['access'] == record[5] and \
                header['ogp_path'] == record[6] and \
                header['category'] == record[7]
    def is_changed_title(self, header, record):
        return not header['title'] == record[3]
```
```python
    def upsert_article(self, article):
        id = article['id']
        is_get_content = True
        method = self._db.insert_article
        if self._db.exists_article(id):
            if not self._db.is_changed_updated(article): return
            method = self._db.update_article if self._db.is_get_content(article) else self._db.update_article_header
        method(article, self._api.article(id) if is_get_content else None)
```

　これでヘッダと本文の両方が更新されているときのDB更新漏れを防げるはず。次回はこうしよう。

選択肢|方法|問題|頻度|致命度
------|----|----|----|------
現状|レコードが既存かつヘッダ項目が同一なら本文またはコメントが更新されたと判断する|ヘッダ項目と本文（またはコメント）の両方が変更されたとき、本文に変更なしと判断されて本文やコメントが更新されない|多|大
別案|レコードが既存かつアクセス数とモナが同一なら本文またはコメントが更新されたと判断する|カテゴリまたはOGPパスのいずれかひとつまたは両方だけが更新されただけなのに、本文またはコメントも更新されたと判断されムダに[article][] APIが発行されてしまう|少|微
次案|現状に加えタイトルが更新されたら本文も更新されたと判断する|タイトルだけ更新したときムダに[article][] APIが発行されてしまう|少＋|微＋

### 現状

* ヘッダ項目＝アクセス数、モナ、OGPパス、カテゴリID

更新されたデータ|本文更新判定・DB更新
----------------|--------------------
ヘッダ項目のみ|❌
本文のみ|⭕
ヘッダ項目と本文|❌
タイトルのみ|⭕
タイトルと本文|⭕

　タイトルのみ変更したとき、ムダに[article][] APIを発行してしまう問題がある。一緒に本文も更新されているときはムダにならない。

### 別案

* ヘッダ項目＝アクセス数、モナ

更新されたデータ|本文更新判定・DB更新
----------------|--------------------
ヘッダ項目のみ|❌
本文のみ|⭕
ヘッダ項目と本文|❌
タイトルのみ|⭕
カテゴリのみ|⭕
OGPパスのみ|⭕

　タイトル、カテゴリ、OGPパス、いずれかひとつまたはそれら複数だけ変更したとき、ムダに[article][] APIを発行してしまう問題がある。

### 次案

* ヘッダ項目＝タイトル、アクセス数、モナ、OGPパス、カテゴリID

更新されたデータ|本文更新判定・DB更新
----------------|--------------------
ヘッダ項目のみ|△
本文のみ|⭕
ヘッダ項目と本文|△
タイトルのみ|⭕
カテゴリのみ|❌
OGPパスのみ|❌

　`△`については、もし更新したヘッダ項目がタイトルであれば本文が更新される。もし更新したヘッダ項目がタイトル以外であれば本文は更新されない。このため、本文を更新するときは一緒にタイトルも更新することでDB更新漏れを回避できる。

　ただしタイトルを更新したときは[article][] APIを必ず発行してしまう。もし本文やコメントに変更がなければムダになる。アクセス数や更新日時も変わってしまう。

# 所感

　つぎは次案を実装してみよう。

