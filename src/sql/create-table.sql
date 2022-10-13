PRAGMA foreign_keys=true;
create table if not exists articles(
    id integer not null primary key,
    article_id integer not null unique,
    created text not null,
    updated text not null,
    title text not null,
    --sent_mona decimal not null,
    --sent_mona integer not null,
    sent_mona text not null,
    access integer not null,
    ogp_path text not null,
    category integer not null,
    content text
);
create table if not exists comments(
    id integer not null primary key,
    comment_id integer not null unique,
    article_id integer not null,
    created integer not null,
    updated integer not null,
    user_id integer not null,
    content text not null,
    foreign key (article_id) references articles(article_id)
);
create table if not exists users(
    id integer not null primary key,
    user_id integer not null unique,
    address text not null unique,
    created integer not null,
    updated integer not null,
    name text not null,
    icon_image_path text
);

