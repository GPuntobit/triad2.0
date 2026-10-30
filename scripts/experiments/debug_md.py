import os, re
root = '.'
exclude = ['.venv', '.git', '.delta', '.webcmd', 'node_modules', '__pycache__']
cnt_md = 0
cnt_acc = 0
for dp, dn, fn in os.walk(root):
    dn[:] = [d for d in dn if d not in exclude]
    for f in fn:
        if not f.endswith('.md'):
            continue
        cnt_md += 1
        p = os.path.join(dp, f)
        try:
            t = open(p, encoding='utf-8', errors='ignore').read()
        except Exception as e:
            print("ERR", p, e)
            continue
        if re.search(r'[àèéìòù]', t):
            cnt_acc += 1
            if cnt_acc <= 10:
                print("ACCENT:", p)
print("total md", cnt_md, "with accents", cnt_acc)
print("cwd", os.getcwd())
