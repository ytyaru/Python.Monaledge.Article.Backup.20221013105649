#!/usr/bin/env bash
set -Ceu
#---------------------------------------------------------------------------
# モナレッジのAPIで指定したユーザの記事を取得する。
# SQLite3 DBファイルに保存したデータをファイルに書き出す。
# https://www.sqlite.org/cli.html
#   writefile(name, content)
#   readfile(name)
#   edit(content, editor)
# CreatedAt: 2022-10-07
#---------------------------------------------------------------------------
Run() {
	THIS="$(realpath "${BASH_SOURCE:-0}")"; HERE="$(dirname "$THIS")"; PARENT="$(dirname "$HERE")"; THIS_NAME="$(basename "$THIS")"; APP_ROOT="$PARENT";
	cd "$HERE"
	[ -f 'error.sh' ] && . error.sh
	FrontMatter() { # https://frontmatter.codes/docs/markdown
		local RECORD="$(sqlite3 -tabs "$DB" "select title, created, updated, category_id from articles where id = ${1};")"
		local TITLE="$(echo "$RECORD" | cut -f1)"
		local CREATED="$(echo "$RECORD" | cut -f2)"
		local UPDATED="$(echo "$RECORD" | cut -f3)"
		local CATEGORY_ID="$(echo "$RECORD" | cut -f4)"
		local CATEGORY="$(sqlite3 "$DB" "select name from categories where id = $CATEGORY_ID;")"
		cat << EOS
---
title: "$TITLE"
date: $CREATED
lastmod: $UPDATED
categories: ["$CATEGORY"]
---
EOS
	}
	escape() { echo "$(cat -)" | sed -e "s/'/''/g"; } # SQLメタ文字であるシングルクォートをエスケープする
	local DB=monaledge.db
	local SQL='select id from articles order by id asc;'
	local DIR=md
	mkdir -p $DIR
	while read id; do
		content="$(FrontMatter $id | escape)"
		content+="\n\n$(sqlite3 "$DB" "select content from articles where id = ${id};" | escape)"
		sqlite3 "$DB" "select writefile('./${DIR}/${id}.md', '$(echo -e "${content}")')"
	done < <(sqlite3 "$DB" "$SQL")

}
Run "$@"

