PRAGMA foreign_keys=true;
create table if not exists articles(
    id integer not null primary key,
    created text not null,
    updated text not null,
    title text not null,
    sent_mona text not null,
    access integer not null,
    ogp_path text not null,
    category_id integer not null,
    content text not null,
    foreign key (category_id) references categories(id)
);

