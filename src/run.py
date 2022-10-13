#!/usr/bin/env python3
# coding: utf8
import sys
from backup import Backup
if __name__ == '__main__':
    if len(sys.argv) < 2:
        print('第一引数が足りません。モナレッジに登録したモナコイン用アドレスを渡してください。', file=sys.stderr)
        sys.exit(1)
    Backup().run(sys.argv[1])
