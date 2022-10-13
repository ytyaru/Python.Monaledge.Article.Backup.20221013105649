create table if not exists categories(
    id integer not null primary key,
    name text not null unique
);
-- https://github.com/Raiu1210/omaemona_front/blob/8174d5d0ff5f37370a7f7f9fd8fdb60daca4ddd1/myModules/categoryUtils.js
insert into categories(id,name) values (0,'未分類'),(1,'その他'),(2,'暗号通貨'),(3,'モナコイン'),(4,'温泉'),(5,'神社・お寺'),(6,'趣味'),(10,'カーライフ'),(7,'日記'),(8,'IT技術'),(9,'ガジェット'),(11,'本'),(12,'創作話'),(13,'怖い話');
