{mylib, ...} @ args:
map (i: import i args) (mylib.scan_path ./.)
