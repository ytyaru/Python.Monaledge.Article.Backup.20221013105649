[ja](./README.ja.md)

# Monaledge.Article.Backup

Save all your articles written in Monalage in SQLite3.

Articles with changed titles will have their text and comments updated. Even if the title, number of monas, number of accesses, category, and OGP image path are not changed, the text and comments are updated even when the update date and time are updated. If the title has not changed and other header items such as update date and time have changed, only the header item is updated. If all header items are the same, do nothing.

<!--

# DEMO

* [demo](https://ytyaru.github.io/Python.Monaledge.Article.Backup.20221013105649/)

![img](https://github.com/ytyaru/Python.Monaledge.Article.Backup.20221013105649/blob/master/doc/0.png?raw=true)

# Features

* sales point

-->

# Requirement

* <time datetime="2022-10-13T10:56:46+0900">2022-10-13</time>
* [Raspbierry Pi](https://ja.wikipedia.org/wiki/Raspberry_Pi) 4 Model B Rev 1.2
* [Raspberry Pi OS](https://ja.wikipedia.org/wiki/Raspbian) buster 10.0 2020-08-20 <small>[setup](http://ytyaru.hatenablog.com/entry/2020/10/06/111111)</small>
* bash 5.0.3(1)-release
* Python 3.10.5

```sh
$ uname -a
Linux raspberrypi 5.10.103-v7l+ #1529 SMP Tue Mar 8 12:24:00 GMT 2022 armv7l GNU/Linux
```

# Installation

```sh
git clone https://github.com/ytyaru/Python.Monaledge.Article.Backup.20221013105649
```

# Usage

```sh
cd Python.Monaledge.Article.Backup.20221013105649/src
ADDRESS='モナレッジに登録した自分のモナコイン用アドレス'
./run.py $ADDRESS
./file.sh
```

File|Use
----|---
`run.py`|Back up the article (get an article from WebAPI and save it in SQLITE3)
`file.sh`|Output the article to the markdown file (output to the markdown from SQLite3)

`run.py` passs the monacoin address to the first number.

# Note

* When only the title is updated but the text is not updated, the access count is incremented by issuing the [Article][] API assuming that the text has been updated

# Author

ytyaru

* [![github](http://www.google.com/s2/favicons?domain=github.com)](https://github.com/ytyaru "github")
* [![hatena](http://www.google.com/s2/favicons?domain=www.hatena.ne.jp)](http://ytyaru.hatenablog.com/ytyaru "hatena")
* [![twitter](http://www.google.com/s2/favicons?domain=twitter.com)](https://twitter.com/ytyaru1 "twitter")
* [![mastodon](http://www.google.com/s2/favicons?domain=mstdn.jp)](https://mstdn.jp/web/accounts/233143 "mastdon")

# License

This software is CC0 licensed.

[![CC0](http://i.creativecommons.org/p/zero/1.0/88x31.png "CC0")](http://creativecommons.org/publicdomain/zero/1.0/deed.en)

