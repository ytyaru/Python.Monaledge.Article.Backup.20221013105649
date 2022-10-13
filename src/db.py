import sqlite3
class Db:
    def __init__(self, path):
        self._path = path
        self._con = sqlite3.connect(self._path)
        self._cur = self._con.cursor()
    def __del__(self): self._con.close()
    def exec(self, sql, datas=()): return self._cur.execute(sql, datas)
    def execm(self, sql, datas=()): return self._cur.executemany(sql, datas)
    def execs(self, sql): return self._cur.executescript(sql)
    def commit(self): return self._con.commit()
    @property
    def Path(self): return self._path
    @Path.setter
    def Path(self, v):
        self._path = v
        self._con = sqlite3.connect(self._path)
        self._cur = self._con.cursor()
    @property
    def Con(self): return self._con
    @property
    def Cur(self): return self._cur
   
