import urllib.request, urllib.parse, json, sys, time

def translate_chunk(text):
    if not text.strip():
        return text
    q = urllib.parse.quote(text)
    url = f"https://translate.googleapis.com/translate_a/single?client=gtx&sl=it&tl=en&dt=t&q={q}"
    for attempt in range(3):
        try:
            with urllib.request.urlopen(url, timeout=20) as r:
                data = json.loads(r.read().decode('utf-8'))
            out = ''
            for seg in data[0]:
                if seg and seg[0]:
                    out += seg[0]
            return out if out else text
        except Exception as e:
            print("ERR", e, file=sys.stderr)
            time.sleep(2)
    return text

def translate_text(text):
    if not text.strip():
        return text
    lines = text.split('\n')
    chunks = []
    cur = []
    cur_len = 0
    for line in lines:
        if cur_len + len(line) + 1 > 2000 and cur:
            chunks.append('\n'.join(cur))
            cur = [line]
            cur_len = len(line)
        else:
            cur.append(line)
            cur_len += len(line) + 1
    if cur:
        chunks.append('\n'.join(cur))
    res = []
    for c in chunks:
        res.append(translate_chunk(c))
        time.sleep(0.2)
    return '\n'.join(res)

def translate_markdown(path_in, path_out):
    lines = open(path_in, encoding='utf-8').read().split('\n')
    out = []
    in_code = False
    buffer = []
    def flush_buffer():
        nonlocal buffer
        if not buffer:
            return
        text = '\n'.join(buffer)
        translated = translate_text(text)
        out.append(translated)
        buffer = []
    for line in lines:
        if line.strip().startswith('```'):
            flush_buffer()
            out.append(line)
            in_code = not in_code
            continue
        if in_code:
            out.append(line)
            continue
        buffer.append(line)
        if line.strip() == '':
            flush_buffer()
    flush_buffer()
    with open(path_out, 'w', encoding='utf-8') as f:
        f.write('\n'.join(out))

if __name__ == '__main__':
    translate_markdown(sys.argv[1], sys.argv[2])
    print("done")
