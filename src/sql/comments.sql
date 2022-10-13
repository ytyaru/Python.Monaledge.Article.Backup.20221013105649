PRAGMA foreign_keys=true;
create table if not exists comments(
    id integer not null primary key,
    article_id integer not null,
    created integer not null,
    updated integer not null,
    user_id integer not null,
    content text not null
    --foreign key (article_id) references articles(id),
    --foreign key (user_id) references users(id)
);
-- 外部キーはやめる。APIで記事取得するとき本文とコメントは一緒に取得される。同時にDB挿入するが先に本文を挿入してコミットしないとコメント挿入したとき外部キーエラー「FOREIGN KEY constraint failed」になる。でもコミットタイミングは同時にしたい。一度の書き込みで完了させることで書き込み回数を減らしたいから。応答速度の向上とディスク劣化最小化のため。よってやむなく外部キー制約をやめることにした。意味的には外部キー制約したいのに。
