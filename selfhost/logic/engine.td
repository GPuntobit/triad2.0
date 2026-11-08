# S1 logic engine. Written in Triad-Core; SPEC.md section 6.
lchars = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","A","B","C","D","E","F"]
lchars2 = ["G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","0","1","2","3","4","5","6","7","8","9","_"]

# Growable vector: at most 4096 cells, 64 chunks of 64 values.
function lv_new()
    vx = [[], 0]
    vx
end
function lv_at(va, vi)
    vc = 0
    while vi >= 64
        vi = vi - 64
        vc = vc + 1
    end
    vr = get(get(get(va, 0), vc), vi)
    vr
end
function lv_set(vb, vj, vy)
    vd = 0
    while vj >= 64
        vj = vj - 64
        vd = vd + 1
    end
    vz = get(get(vb, 0), vd)
    vz[vj + 1] = vy
    vy
end
function lv_add(ve, vw)
    vn = get(ve, 1)
    if vn >= 4096
        println("LOGIC: CAPACITY EXCEEDED")
        logic_abort()
    end
    vg = get(ve, 0)
    if vn % 64 == 0
        vg = push!(vg, [])
    end
    vh = get(vg, length(vg) - 1)
    vh = push!(vh, vw)
    ve[2] = vn + 1
    vw
end
function lv_pop(vf)
    vk = get(vf, 1) - 1
    vl = lv_at(vf, vk)
    vf[2] = vk
    vl
end
# Stack slots are reused, not appended after a pop.
function lv_put(vp, vq)
    vt = get(vp, 1)
    vu = get(vp, 0)
    vs = 0
    vrm = vt
    while vrm >= 64
        vrm = vrm - 64
        vs = vs + 1
    end
    if vs < length(vu)
        vchunk = get(vu, vs)
        if vrm < length(vchunk)
            vchunk[vrm + 1] = vq
            vp[2] = vt + 1
        else
            lv_add(vp, vq)
        end
    else
        lv_add(vp, vq)
    end
    vq
end
function lc_text(cc)
    cr = ""
    if (cc >= 97) && (cc <= 122)
        cr = get(lchars, cc - 97)
    elseif (cc >= 65) && (cc <= 90)
        cp = cc - 65 + 26
        if cp < 32
            cr = get(lchars, cp)
        else
            cr = get(lchars2, cp - 32)
        end
    elseif (cc >= 48) && (cc <= 57)
        cr = get(lchars2, cc - 48 + 20)
    elseif cc == 95
        cr = "_"
    elseif cc == 32
        cr = " "
    elseif cc == 43
        cr = "+"
    elseif cc == 45
        cr = "-"
    elseif cc == 42
        cr = "*"
    elseif cc == 37
        cr = "%"
    elseif cc == 46
        cr = "."
    elseif cc == 58
        cr = ":"
    elseif cc == 47
        cr = "/"
    elseif cc == 33
        cr = "!"
    elseif cc == 63
        cr = "?"
    elseif cc == 44
        cr = ","
    elseif cc == 40
        cr = "("
    elseif cc == 41
        cr = ")"
    elseif cc == 91
        cr = "["
    elseif cc == 93
        cr = "]"
    elseif cc == 61
        cr = "="
    elseif cc == 60
        cr = "<"
    elseif cc == 62
        cr = ">"
    else
        println("LOGIC: UNSUPPORTED TEXT BYTE " * string(cc))
        logic_abort()
    end
    cr
end
function ln_eq(na, nb)
    nr = get(na, 1) == get(nb, 1)
    ni = 0
    while (ni < get(na, 1)) && nr
        nr = lv_at(na, ni) == lv_at(nb, ni)
        ni = ni + 1
    end
    nr
end
function ln_id(nv)
    nx = 0
    nn = 0
    while nn < get(lnames, 1)
        ne = lv_at(lnames, nn)
        if ln_eq(get(ne, 0), nv)
            nx = nn + 1
            nn = get(lnames, 1)
        else
            nn = nn + 1
        end
    end
    if nx == 0
        ns = ""
        nj = 0
        while nj < get(nv, 1)
            ns = ns * lc_text(lv_at(nv, nj))
            nj = nj + 1
        end
        lv_add(lnames, [nv, ns])
        nx = get(lnames, 1)
    end
    nx
end
function ln_text(nt)
    nz = get(lv_at(lnames, nt - 1), 1)
    nz
end
# S0 has no usable exit builtin yet. A checked bounds failure terminates
# both runtimes after the preceding S1 diagnostic, without undefined calls.
function logic_abort()
    axx = []
    axr = get(axx, 0)
    axr
end
function lx_bad()
    println("LOGIC: SYNTAX ERROR")
    logic_abort()
    0
end
function lx_alpha(la)
    lr = ((la >= 65) && (la <= 90)) || ((la >= 97) && (la <= 122)) || (la == 95)
    lr
end
function lx_digit(lb)
    ls = (lb >= 48) && (lb <= 57)
    ls
end
function lbyte(bi)
    bc = 0
    while bi >= 64
        bi = bi - 64
        bc = bc + 1
    end
    bb = lv_at(ldata, bc)
    br = get(bb, bi)
    br
end
function lx_name()
    nbv = lv_new()
    while lx_alpha(lbyte(lsrc[1])) || lx_digit(lbyte(lsrc[1]))
        lv_add(nbv, lbyte(lsrc[1]))
        lsrc[1] = lsrc[1] + 1
    end
    if lbyte(lsrc[1]) == 33
        lv_add(nbv, 33)
        lsrc[1] = lsrc[1] + 1
    end
    nid = ln_id(nbv)
    nid
end
function lx_all()
    while lsrc[1] < lsize - 1
        ax = lbyte(lsrc[1])
        lsrc[1] = lsrc[1] + 1
        if (ax == 32) || (ax == 9) || (ax == 13)
            ax = 0
        elseif ax == 35
            if lbyte(lsrc[1]) == 61
                lsrc[1] = lsrc[1] + 1
                ac = true
                while ac
                    abx = lbyte(lsrc[1])
                    if abx == 0
                        lx_bad()
                    end
                    lsrc[1] = lsrc[1] + 1
                    if (abx == 61) && (lbyte(lsrc[1]) == 35)
                        lsrc[1] = lsrc[1] + 1
                        ac = false
                    end
                end
            else
                while (lbyte(lsrc[1]) != 10) && (lbyte(lsrc[1]) != 0)
                    lsrc[1] = lsrc[1] + 1
                end
            end
        elseif (ax == 10) || (ax == 59)
            lv_add(ltoks, [11, 0])
        elseif lx_alpha(ax)
            lsrc[1] = lsrc[1] - 1
            an = lx_name()
            lv_add(ltoks, [1, an])
        elseif (ax == 63) || (ax == 58)
            if (ax == 58) && (lbyte(lsrc[1]) == 58)
                lsrc[1] = lsrc[1] + 1
                lv_add(ltoks, [31, 0])
            elseif (ax == 58) && (lbyte(lsrc[1]) == 45)
                lsrc[1] = lsrc[1] + 1
                lv_add(ltoks, [12, 0])
            else
                if !lx_alpha(lbyte(lsrc[1]))
                    lx_bad()
                end
                an = lx_name()
                ak = 2
                if ax == 58
                    ak = 3
                end
                lv_add(ltoks, [ak, an])
            end
        elseif lx_digit(ax)
            av = ax - 48
            while lx_digit(lbyte(lsrc[1]))
                av = av * 10 + lbyte(lsrc[1]) - 48
                lsrc[1] = lsrc[1] + 1
            end
            lv_add(ltoks, [4, av])
        elseif ax == 34
            ab = lv_new()
            while (lbyte(lsrc[1]) != 34) && (lbyte(lsrc[1]) != 0)
                lv_add(ab, lbyte(lsrc[1]))
                lsrc[1] = lsrc[1] + 1
            end
            if lbyte(lsrc[1]) != 34
                lx_bad()
            end
            lsrc[1] = lsrc[1] + 1
            ai = ln_id(ab)
            lv_add(ltoks, [5, ai])
        else
            ak = 0
            if ax == 40
                ak = 6
            elseif ax == 41
                ak = 7
            elseif ax == 91
                ak = 8
            elseif ax == 93
                ak = 9
            elseif ax == 44
                ak = 10
            elseif ax == 61
                ak = 13
                if lbyte(lsrc[1]) == 61
                    ak = 22
                    lsrc[1] = lsrc[1] + 1
                end
            elseif ax == 38
                if lbyte(lsrc[1]) != 38
                    lx_bad()
                end
                lsrc[1] = lsrc[1] + 1
                ak = 14
            elseif ax == 124
                ak = 27
                if lbyte(lsrc[1]) == 124
                    ak = 15
                    lsrc[1] = lsrc[1] + 1
                end
            elseif ax == 33
                ak = 16
                if lbyte(lsrc[1]) == 61
                    ak = 21
                    lsrc[1] = lsrc[1] + 1
                end
            elseif ax == 60
                ak = 17
                if lbyte(lsrc[1]) == 61
                    ak = 18
                    lsrc[1] = lsrc[1] + 1
                end
            elseif ax == 62
                ak = 19
                if lbyte(lsrc[1]) == 61
                    ak = 20
                    lsrc[1] = lsrc[1] + 1
                end
            elseif ax == 43
                ak = 23
            elseif ax == 45
                ak = 24
            elseif ax == 42
                ak = 25
            elseif ax == 37
                ak = 26
            elseif ax == 46
                ak = 28
            elseif ax == 36
                ak = 29
            end
            if ak == 0
                lx_bad()
            end
            lv_add(ltoks, [ak, 0])
        end
    end
    lv_add(ltoks, [0, 0])
    0
end
function pk()
    pr = get(lv_at(ltoks, lp[1]), 0)
    pr
end
function pn()
    ps = get(lv_at(ltoks, lp[1]), 1)
    ps
end
function eat(ek)
    if pk() != ek
        lx_bad()
    end
    lp[1] = lp[1] + 1
    0
end
function gaps()
    while pk() == 11
        lp[1] = lp[1] + 1
    end
    0
end
function atom()
    tk = pk()
    tv = pn()
    lp[1] = lp[1] + 1
    tr = [0, 0]
    if tk == 2
        tr = [1, tv]
    elseif tk == 3
        tr = [2, tv]
    elseif tk == 4
        tr = [3, tv]
    elseif tk == 5
        tr = [4, tv]
    elseif tk == 24
        ta = atom()
        if get(ta, 0) == 3
            tr = [3, 0 - get(ta, 1)]
        else
            tr = [5, kop_sub, [ta]]
        end
    elseif tk == 29
        eat(6)
        txv = expr()
        eat(7)
        tr = [23, txv]
    elseif tk == 6
        tr = expr()
        eat(7)
    elseif tk == 8
        gaps()
        if pk() == 9
            tr = [6, 0, 0]
            eat(9)
        else
            ta = expr()
            if (pk() == 1) && (pn() == kw_for)
                lp[1] = lp[1] + 1
                tb = pn()
                eat(1)
                if pn() != kw_in
                    lx_bad()
                end
                eat(1)
                tc = expr()
                tfilter = [37, 1]
                if (pk() == 1) && (pn() == kw_cond)
                    eat(1)
                    tfilter = goal_or()
                end
                eat(9)
                tr = [22, ta, tb, tc, tfilter]
            else
                tl = lv_new()
                lv_add(tl, ta)
                gaps()
                while pk() == 10
                    eat(10)
                    gaps()
                    ta = expr()
                    lv_add(tl, ta)
                    gaps()
                end
                tt = [6, 0, 0]
                if pk() == 27
                    eat(27)
                    tt = expr()
                end
                eat(9)
                ti = get(tl, 1) - 1
                while ti >= 0
                    tt = [6, lv_at(tl, ti), tt]
                    ti = ti - 1
                end
                tr = tt
            end
        end
    elseif tk == 1
        if tv == kw_solve
            tg = goal_or()
            tlim = 1000000
            tdep = 1000000
            tstep = 1000000
            ttrace = false
            tx = 1
            while (pk() == 1) && (tx == 1)
                to = pn()
                if (to == kw_limit) || (to == kw_depth) || (to == kw_steps)
                    lp[1] = lp[1] + 1
                    tn = pn()
                    eat(4)
                    if to == kw_limit
                        tlim = tn
                    elseif to == kw_depth
                        tdep = tn
                    else
                        tstep = tn
                    end
                elseif to == kw_trace
                    lp[1] = lp[1] + 1
                    ttrace = true
                else
                    tx = 0
                end
            end
            tr = [20, tg, tlim, tdep, tstep, ttrace]
        elseif tv == kw_true
            tr = [8, 1]
        elseif tv == kw_false
            tr = [8, 0]
        elseif pk() == 6
            eat(6)
            tvs = lv_new()
            if pk() != 7
                ta = expr()
                lv_add(tvs, ta)
                while pk() == 10
                    eat(10)
                    ta = expr()
                    lv_add(tvs, ta)
                end
            end
            eat(7)
            # Compound arguments fit in the seed's 64-item list.
            targs = []
            ti = 0
            while ti < get(tvs, 1)
                targs = push!(targs, lv_at(tvs, ti))
                ti = ti + 1
            end
            tr = [5, tv, targs]
        else
            tr = [9, tv]
        end
    else
        lx_bad()
    end
    while pk() == 28
        eat(28)
        tf = pn()
        eat(1)
        tr = [21, tr, tf]
    end
    tr
end
function product()
    ma = atom()
    while (pk() == 25) || (pk() == 26)
        mo = kop_mul
        if pk() == 26
            mo = kop_mod
        end
        lp[1] = lp[1] + 1
        mb = atom()
        ma = [5, mo, [ma, mb]]
    end
    ma
end
function expr()
    ea = product()
    while (pk() == 23) || (pk() == 24)
        eo = kop_add
        if pk() == 24
            eo = kop_sub
        end
        lp[1] = lp[1] + 1
        eb = product()
        ea = [5, eo, [ea, eb]]
    end
    ea
end
function goal_atom()
    ga = [37, 1]
    if (pk() == 16) || ((pk() == 1) && (pn() == kw_not))
        lp[1] = lp[1] + 1
        gb = goal_atom()
        ga = [33, gb]
    elseif pk() == 6
        eat(6)
        ga = goal_or()
        eat(7)
    else
        gc = expr()
        go = pk()
        if (go >= 17) && (go <= 22)
            lp[1] = lp[1] + 1
            gd = expr()
            ga = [35, go, gc, gd]
        elseif go == 13
            eat(13)
            gd = expr()
            ga = [34, gc, gd]
        elseif (go == 1) && (pn() == kw_is)
            eat(1)
            gd = expr()
            ga = [36, gc, gd]
        elseif get(gc, 0) == 8
            ga = [37, get(gc, 1)]
        else
            ga = [30, gc]
        end
    end
    ga
end
function goal_and()
    ha = goal_atom()
    while (pk() == 10) || (pk() == 14)
        lp[1] = lp[1] + 1
        hb = goal_atom()
        ha = [31, ha, hb]
    end
    ha
end
function goal_or()
    oa = goal_and()
    while pk() == 15
        lp[1] = lp[1] + 1
        ob = goal_and()
        oa = [32, oa, ob]
    end
    oa
end

# Runtime terms and iterative unification with an undo trail.
function lderef(da)
    dr = da
    dx = 1
    while (get(dr, 0) == 1) && (dx == 1)
        dv = lv_at(lbind, get(dr, 1))
        if dv == 0
            dx = 0
        else
            dr = dv
        end
    end
    dr
end
function lvar(vname)
    vid = get(lbind, 1)
    lv_add(lbind, 0)
    lv_add(lvnames, vname)
    vt = [1, vid]
    vt
end
function lc_term(ca, cm)
    ck = get(ca, 0)
    cv = get(ca, 1)
    ct = ca
    if ck == 1
        if cm != 0
        ci = 0
        ct = 0
        while ci < get(cm, 1)
            ce = lv_at(cm, ci)
            if (get(ce, 0) == cv) && (cv != kw_anon)
                ct = get(ce, 1)
            end
            ci = ci + 1
        end
        if ct == 0
            ct = lvar(cv)
            if cv != kw_anon
                lv_add(cm, [cv, ct])
            end
        end
        else
            ct = ca
        end
    elseif ck == 9
        ct = le_lookup(cv)
    elseif ck == 23
        ct = leval(cv)
    elseif ck == 5
        cb = get(ca, 2)
        cc = []
        cj = 0
        while cj < length(cb)
            cd = lc_term(get(cb, cj), cm)
            cc = push!(cc, cd)
            cj = cj + 1
        end
        ct = [5, cv, cc]
    elseif (ck == 6) && (cv != 0)
        ch = lc_term(cv, cm)
        cz = lc_term(get(ca, 2), cm)
        ct = [6, ch, cz]
    end
    ct
end
function lc_goal(qa, qm)
    qk = get(qa, 0)
    qr = qa
    if qk == 30
        qt = lc_term(get(qa, 1), qm)
        qr = [30, qt]
    elseif (qk == 31) || (qk == 32)
        qx = lc_goal(get(qa, 1), qm)
        qy = lc_goal(get(qa, 2), qm)
        qr = [qk, qx, qy]
    elseif qk == 33
        qx = lc_goal(get(qa, 1), qm)
        qr = [33, qx]
    elseif (qk == 34) || (qk == 36)
        qx = lc_term(get(qa, 1), qm)
        qy = lc_term(get(qa, 2), qm)
        qr = [qk, qx, qy]
    elseif qk == 35
        qx = lc_term(get(qa, 2), qm)
        qy = lc_term(get(qa, 3), qm)
        qr = [35, get(qa, 1), qx, qy]
    end
    qr
end
function locc(ov, ot)
    ost = lv_new()
    lv_put(ost, ot)
    orr = false
    while (get(ost, 1) > 0) && !orr
        ox = lv_pop(ost)
        ox = lderef(ox)
        ok = get(ox, 0)
        if ok == 1
            orr = get(ox, 1) == ov
        elseif ok == 5
            oa = get(ox, 2)
            oi = 0
            while oi < length(oa)
                lv_put(ost, get(oa, oi))
                oi = oi + 1
            end
        elseif (ok == 6) && (get(ox, 1) != 0)
            lv_put(ost, get(ox, 1))
            lv_put(ost, get(ox, 2))
        end
    end
    orr
end
function lu(ua, ub)
    us = lv_new()
    lv_put(us, [ua, ub])
    ur = true
    while (get(us, 1) > 0) && ur
        up = lv_pop(us)
        ux = lderef(get(up, 0))
        uy = lderef(get(up, 1))
        uk = get(ux, 0)
        uj = get(uy, 0)
        if (uk == 1) && (uj == 1) && (get(ux, 1) == get(uy, 1))
            ur = true
        elseif uk == 1
            uv = get(ux, 1)
            if locc(uv, uy)
                ur = false
            else
                lv_set(lbind, uv, uy)
                lv_put(ltrail, uv)
            end
        elseif uj == 1
            uv = get(uy, 1)
            if locc(uv, ux)
                ur = false
            else
                lv_set(lbind, uv, ux)
                lv_put(ltrail, uv)
            end
        elseif uk != uj
            ur = false
        elseif uk == 5
            uvx = get(ux, 2)
            uvy = get(uy, 2)
            ur = (get(ux, 1) == get(uy, 1)) && (length(uvx) == length(uvy))
            ui = 0
            while (ui < length(uvx)) && ur
                lv_put(us, [get(uvx, ui), get(uvy, ui)])
                ui = ui + 1
            end
        elseif uk == 6
            if (get(ux, 1) == 0) || (get(uy, 1) == 0)
                ur = (get(ux, 1) == 0) && (get(uy, 1) == 0)
            else
                lv_put(us, [get(ux, 1), get(uy, 1)])
                lv_put(us, [get(ux, 2), get(uy, 2)])
            end
        else
            ur = get(ux, 1) == get(uy, 1)
        end
    end
    ur
end
function lundo(um)
    while get(ltrail, 1) > um
        uz = lv_pop(ltrail)
        lv_set(lbind, uz, 0)
    end
    0
end
function lsnap(sa)
    sx = lderef(sa)
    sk = get(sx, 0)
    sr = sx
    if sk == 5
        sb = get(sx, 2)
        sc = []
        si = 0
        while si < length(sb)
            sd = lsnap(get(sb, si))
            sc = push!(sc, sd)
            si = si + 1
        end
        sr = [5, get(sx, 1), sc]
    elseif (sk == 6) && (get(sx, 1) != 0)
        sh = lsnap(get(sx, 1))
        sz = lsnap(get(sx, 2))
        sr = [6, sh, sz]
    end
    sr
end
function le_lookup(en)
    ei = 0
    er = 0
    while ei < get(lenv, 1)
        ev = lv_at(lenv, ei)
        if get(ev, 0) == en
            er = get(ev, 1)
        end
        ei = ei + 1
    end
    if er == 0
        println("LOGIC: UNBOUND VALUE " * ln_text(en))
        logic_abort()
    end
    er
end
function le_set(ex, ey)
    ej = 0
    ez = 0
    while ej < get(lenv, 1)
        eb = lv_at(lenv, ej)
        if get(eb, 0) == ex
            eb[2] = ey
            ez = 1
        end
        ej = ej + 1
    end
    if ez == 0
        lv_put(lenv, [ex, ey])
    end
    ey
end
function lcalc(aa)
    ar = lderef(aa)
    if get(ar, 0) == 21
        ar = leval(ar)
    end
    if get(ar, 0) == 5
        ao = get(ar, 1)
        ap = get(ar, 2)
        ax = lcalc(get(ap, 0))
        if get(ax, 0) == 11
            ar = ax
        elseif get(ax, 0) != 3
            ar = [11, err_type]
        elseif length(ap) == 1
            ar = [3, 0 - get(ax, 1)]
        else
            ay = lcalc(get(ap, 1))
            if get(ay, 0) == 11
                ar = ay
            elseif get(ay, 0) != 3
                ar = [11, err_type]
            else
                av = get(ax, 1)
                aw = get(ay, 1)
                az = 0
                if ao == kop_add
                    az = av + aw
                elseif ao == kop_sub
                    az = av - aw
                elseif ao == kop_mul
                    az = av * aw
                elseif (ao == kop_mod) && (aw != 0)
                    az = av % aw
                else
                    az = 0
                end
                ar = [3, az]
                if (ao == kop_mod) && (aw == 0)
                    ar = [11, err_arith]
                end
                if (ao != kop_add) && (ao != kop_sub) && (ao != kop_mul) && (ao != kop_mod)
                    ar = [11, err_undef]
                end
            end
        end
    elseif get(ar, 0) == 1
        ar = [11, err_inst]
    end
    ar
end
function lmatch(pa, pb)
    pm = (get(pa, 0) == 5) && (get(pb, 0) == 5)
    if pm
        pm = (get(pa, 1) == get(pb, 1)) && (length(get(pa, 2)) == length(get(pb, 2)))
    end
    pm
end
function lsolve(zg, zl, zd, zs)
    ztr = get(ltrflag, 0)
    ltrflag[1] = false
    zevents = lv_new()
    zm = lv_new()
    zgoal = lc_goal(zg, zm)
    zout = [6, 0, 0]
    zvals = lv_new()
    zcs = lv_new()
    zmark = get(ltrail, 1)
    lv_put(zcs, [[zgoal, 0], zmark, 0])
    zcount = 0
    zstop = false
    zerr = 0
    while (get(zcs, 1) > 0) && (get(zvals, 1) < zl) && !zstop
        zstate = lv_pop(zcs)
        lundo(get(zstate, 1))
        ztodo = get(zstate, 0)
        zlevel = get(zstate, 2)
        zlive = true
        while (ztodo != 0) && zlive && !zstop
            zcount = zcount + 1
            if zcount > zs
                zerr = [11, err_budget]
                zstop = true
            else
                za = get(ztodo, 0)
                ztodo = get(ztodo, 1)
                zk = get(za, 0)
                if zk == 31
                    ztodo = [get(za, 1), [get(za, 2), ztodo]]
                elseif zk == 32
                    lv_put(zcs, [[get(za, 2), ztodo], get(ltrail, 1), zlevel])
                    ztodo = [get(za, 1), ztodo]
                elseif zk == 33
                    zbarr = get(zcs, 1)
                    lv_put(zcs, [ztodo, get(ltrail, 1), zlevel])
                    ztodo = [get(za, 1), [[39, zbarr], 0]]
                elseif zk == 39
                    zcut = get(za, 1)
                    while get(zcs, 1) > zcut
                        lv_pop(zcs)
                    end
                    zlive = false
                elseif zk == 34
                    zlive = lu(get(za, 1), get(za, 2))
                elseif zk == 36
                    zval = lcalc(get(za, 2))
                    if get(zval, 0) == 11
                        zerr = zval
                        zstop = true
                    else
                        zlive = lu(get(za, 1), zval)
                    end
                elseif zk == 35
                    zx = lcalc(get(za, 2))
                    zy = lcalc(get(za, 3))
                    if (get(zx, 0) == 11) || (get(zy, 0) == 11)
                        zerr = [11, err_inst]
                        zstop = true
                    else
                        zo = get(za, 1)
                        zn = get(zx, 1)
                        zp = get(zy, 1)
                        zsame = get(zx, 0) == get(zy, 0)
                        if zo == 17
                            zlive = zn < zp
                        elseif zo == 18
                            zlive = zn <= zp
                        elseif zo == 19
                            zlive = zn > zp
                        elseif zo == 20
                            zlive = zn >= zp
                        elseif zo == 21
                            zlive = !zsame || (zn != zp)
                        else
                            zlive = zsame && (zn == zp)
                        end
                        if (zo >= 17) && (zo <= 20) && ((get(zx, 0) != 3) || (get(zy, 0) != 3))
                            zerr = [11, err_type]
                            zstop = true
                        end
                    end
                elseif zk == 37
                    zlive = get(za, 1) == 1
                elseif zk == 40
                    zb = get(za, 3)
                    zb[1] = true
                    if ztr
                        lt_event(zevents, kw_exit, get(za, 1), get(za, 2))
                    end
                elseif zk == 41
                    if ztr
                        if get(get(za, 3), 0)
                            lt_event(zevents, kw_redo, get(za, 1), get(za, 2))
                        end
                        lt_event(zevents, kw_fail, get(za, 1), get(za, 2))
                    end
                    zlive = false
                elseif zk == 38
                    if ztr && (get(get(za, 3), 0))
                        lt_event(zevents, kw_redo, get(za, 1), zlevel)
                        zb = get(za, 3)
                        zb[1] = false
                    end
                    zcp = get(za, 2)
                    zmap = lv_new()
                    zhead = lc_term(get(zcp, 0), zmap)
                    zbody = lc_goal(get(zcp, 1), zmap)
                    zlive = lu(get(za, 1), zhead)
                    if zlive
                        ztodo = [zbody, [[40, get(za, 1), zlevel, get(za, 3)], ztodo]]
                        zlevel = zlevel + 1
                    end
                elseif zk == 30
                    zterm = lderef(get(za, 1))
                    zbox = [false]
                    if ztr
                        lt_event(zevents, kw_call, zterm, zlevel)
                    end
                    zci = get(lclauses, 1) - 1
                    if ztr
                        lv_put(zcs, [[[41, zterm, zlevel, zbox], 0], get(ltrail, 1), zlevel])
                    end
                    zknown = false
                    while zci >= 0
                        zcl = lv_at(lclauses, zci)
                        if lmatch(zterm, get(zcl, 0))
                            zknown = true
                            if zlevel < zd
                                lv_put(zcs, [[[38, zterm, zcl, zbox], ztodo], get(ltrail, 1), zlevel])
                            elseif ztr
                                lt_event(zevents, kw_depth, zterm, zlevel)
                            end
                        end
                        zci = zci - 1
                    end
                    if !zknown
                        zerr = [11, err_undef]
                        zstop = true
                    end
                    zlive = false
                end
            end
        end
        if zlive && !zstop
            zsol = lv_new()
            zi = 0
            while zi < get(zm, 1)
                ze = lv_at(zm, zi)
                zv = lsnap(get(ze, 1))
                lv_add(zsol, [get(ze, 0), zv])
                zi = zi + 1
            end
            lv_add(zvals, [7, zsol])
        end
    end
    lundo(zmark)
    zi = get(zvals, 1) - 1
    while zi >= 0
        zout = [6, lv_at(zvals, zi), zout]
        zi = zi - 1
    end
    if zerr != 0
        zout = zerr
    end
    if ztr
        zelist = [6, 0, 0]
        zei = get(zevents, 1) - 1
        while zei >= 0
            zelist = [6, lv_at(zevents, zei), zelist]
            zei = zei - 1
        end
        zout = [25, zout, zelist]
    end
    zout
end
function leval(fa)
    fk = get(fa, 0)
    fr = fa
    if fk == 9
        fr = le_lookup(get(fa, 1))
    elseif fk == 20
        ltrflag[1] = get(fa, 5)
        fr = lsolve(get(fa, 1), get(fa, 2), get(fa, 3), get(fa, 4))
    elseif fk == 21
        fb = leval(get(fa, 1))
        fs = lv_new()
        if get(fb, 0) == 7
            fs = get(fb, 1)
        elseif get(fb, 0) == 25
            lv_add(fs, [kw_result, get(fb, 1)])
            lv_add(fs, [kw_trace, get(fb, 2)])
        elseif get(fb, 0) == 24
            lv_add(fs, [kw_port, [2, get(fb, 1)]])
            lv_add(fs, [kw_goal, get(fb, 2)])
            lv_add(fs, [kw_depth, [3, get(fb, 3)]])
        elseif get(fb, 0) == 5
            fj = 0
            while fj < get(lstructs, 1)
                fc = lv_at(lstructs, fj)
                if get(fc, 0) == get(fb, 1)
                    ff = get(fc, 1)
                    fu = 0
                    while fu < length(ff)
                        lv_add(fs, [get(ff, fu), get(get(fb, 2), fu)])
                        fu = fu + 1
                    end
                end
                fj = fj + 1
            end
        else
            lx_bad()
        end
        fi = 0
        fr = 0
        while fi < get(fs, 1)
            fe = lv_at(fs, fi)
            if get(fe, 0) == get(fa, 2)
                fr = get(fe, 1)
            end
            fi = fi + 1
        end
        if fr == 0
            lx_bad()
        end
    elseif fk == 22
        fseq = leval(get(fa, 3))
        fcap = get(lenv, 1)
        fsaved = 0
        fi = 0
        while fi < fcap
            fe = lv_at(lenv, fi)
            if get(fe, 0) == get(fa, 2)
                fsaved = get(fe, 1)
            end
            fi = fi + 1
        end
        fvec = lv_new()
        while (get(fseq, 0) == 6) && (get(fseq, 1) != 0)
            le_set(get(fa, 2), get(fseq, 1))
            ftest = lsolve(get(fa, 4), 1, 1000000, 1000000)
            if (get(ftest, 0) == 6) && (get(ftest, 1) != 0)
                fv = leval(get(fa, 1))
                lv_add(fvec, fv)
            end
            fseq = get(fseq, 2)
        end
        if fsaved != 0
            le_set(get(fa, 2), fsaved)
        end
        lenv[2] = fcap
        fr = [6, 0, 0]
        fi = get(fvec, 1) - 1
        while fi >= 0
            fr = [6, lv_at(fvec, fi), fr]
            fi = fi - 1
        end
    elseif fk == 5
        fop = get(fa, 1)
        if (fop == kop_add) || (fop == kop_sub) || (fop == kop_mul) || (fop == kop_mod)
            fm = lv_new()
            fn = lc_term(fa, fm)
            fr = lcalc(fn)
        else
            fcidx = 0
            fctor = false
            ftypes = []
            while fcidx < get(lstructs, 1)
                fcdef = lv_at(lstructs, fcidx)
                if get(fcdef, 0) == fop
                    fctor = true
                    ftypes = get(fcdef, 2)
                    if length(get(fcdef, 1)) != length(get(fa, 2))
                        lx_bad()
                    end
                end
                fcidx = fcidx + 1
            end
            if fctor
                fargs = []
                fcidx = 0
                while fcidx < length(get(fa, 2))
                    fitem = leval(get(get(fa, 2), fcidx))
                    fargs = push!(fargs, fitem)
                    fcidx = fcidx + 1
                end
                fr = [5, fop, fargs]
                fcidx = 0
                while fcidx < length(fargs)
                    ftype = get(ftypes, fcidx)
                    fvalue = get(fargs, fcidx)
                    fvalid = (ftype == 0) || ((ftype == ty_int) && (get(fvalue, 0) == 3)) || ((ftype == ty_bool) && (get(fvalue, 0) == 8)) || ((ftype == ty_string) && (get(fvalue, 0) == 4)) || ((ftype == ty_symbol) && (get(fvalue, 0) == 2)) || ((ftype == ty_list) && (get(fvalue, 0) == 6))
                    if !fvalid
                        if get(fvalue, 0) == 5
                            fvalid = get(fvalue, 1) == ftype
                        end
                    end
                    if !fvalid
                        fr = [11, err_type]
                    end
                    fcidx = fcidx + 1
                end
            else
            fpred = lsolve([30, fa], 1, 1000000, 1000000)
            if get(fpred, 0) == 11
                fr = fpred
            else
                fr = [8, 0]
                if get(fpred, 1) != 0
                    fr = [8, 1]
                end
            end
            end
        end
    elseif fk == 6
        if get(fa, 1) != 0
            fh = leval(get(fa, 1))
            ft = leval(get(fa, 2))
            fr = [6, fh, ft]
        end
    end
    fr
end
function lshow(ra, nested)
    rk = get(ra, 0)
    rr = ""
    if rk == 1
        ri = get(ra, 1)
        rr = "?" * ln_text(lv_at(lvnames, ri)) * "#" * string(ri)
    elseif rk == 2
        if nested
            rr = ":"
        end
        rr = rr * ln_text(get(ra, 1))
    elseif rk == 3
        rr = string(get(ra, 1))
    elseif rk == 4
        rr = ln_text(get(ra, 1))
    elseif rk == 5
        rr = ln_text(get(ra, 1)) * "("
        rargs = get(ra, 2)
        ri = 0
        while ri < length(rargs)
            if ri > 0
                rr = rr * ", "
            end
            rt = lshow(get(rargs, ri), true)
            rr = rr * rt
            ri = ri + 1
        end
        rr = rr * ")"
    elseif rk == 6
        rr = "["
        rn = ra
        rfirst = true
        while (get(rn, 0) == 6) && (get(rn, 1) != 0)
            if !rfirst
                rr = rr * ", "
            end
            rt = lshow(get(rn, 1), true)
            rr = rr * rt
            rn = get(rn, 2)
            rfirst = false
        end
        if get(rn, 0) != 6
            rt = lshow(rn, true)
            rr = rr * " | " * rt
        end
        rr = rr * "]"
    elseif rk == 7
        rr = "{"
        rv = get(ra, 1)
        ri = 0
        while ri < get(rv, 1)
            if ri > 0
                rr = rr * ", "
            end
            re = lv_at(rv, ri)
            rt = lshow(get(re, 1), true)
            rr = rr * ln_text(get(re, 0)) * " = " * rt
            ri = ri + 1
        end
        rr = rr * "}"
    elseif rk == 8
        rr = "false"
        if get(ra, 1) == 1
            rr = "true"
        end
    elseif rk == 24
        rg = lshow(get(ra, 2), true)
        rr = "Event(port = :" * ln_text(get(ra, 1)) * ", goal = " * rg * ", depth = " * string(get(ra, 3)) * ")"
    elseif rk == 25
        rg = lshow(get(ra, 1), true)
        rh = lshow(get(ra, 2), true)
        rr = "Traced(" * rg * ", " * rh * ")"
    elseif rk == 11
        rr = "Err(:" * ln_text(get(ra, 1)) * ")"
    end
    rr
end
function lt_event(ev, ep, eg, ed)
    et = lsnap(eg)
    lv_add(ev, [24, ep, et, ed])
    0
end
function lf_term(xa, xp)
    xr = xa
    xk = get(xa, 0)
    if xk == 9
        xi = 0
        while xi < length(xp)
            if get(xp, xi) == get(xa, 1)
                xr = [1, get(xa, 1)]
            end
            xi = xi + 1
        end
        if get(xr, 0) == 9
            xr = le_lookup(get(xa, 1))
        end
    elseif xk == 5
        xx = []
        xi = 0
        while xi < length(get(xa, 2))
            xe = lf_term(get(get(xa, 2), xi), xp)
            xx = push!(xx, xe)
            xi = xi + 1
        end
        xr = [5, get(xa, 1), xx]
    end
    xr
end
function lf_goal(ya, yp)
    yr = ya
    yk = get(ya, 0)
    if (yk == 31) || (yk == 32)
        yx = lf_goal(get(ya, 1), yp)
        yy = lf_goal(get(ya, 2), yp)
        yr = [yk, yx, yy]
    elseif yk == 33
        yx = lf_goal(get(ya, 1), yp)
        yr = [33, yx]
    elseif (yk == 34) || (yk == 36)
        yx = lf_term(get(ya, 1), yp)
        yy = lf_term(get(ya, 2), yp)
        yr = [yk, yx, yy]
    elseif yk == 35
        yx = lf_term(get(ya, 2), yp)
        yy = lf_term(get(ya, 3), yp)
        yr = [35, get(ya, 1), yx, yy]
    elseif yk == 30
        yx = lf_term(get(ya, 1), yp)
        yr = [30, yx]
    end
    yr
end
function lrun()
    gaps()
    while pk() != 0
        sn = pn()
        eat(1)
        sbk = sn == kw_fn
        if sbk
            sn = pn()
            eat(1)
        end
        if sn == kw_fact
            sc = expr()
            sh = lc_term(sc, 0)
            lv_add(lclauses, [sh, [37, 1]])
        elseif sn == kw_struct
            sx = pn()
            eat(1)
            gaps()
            sf = []
            sty = []
            while (pk() == 1) && (pn() != kw_stop)
                sf = push!(sf, pn())
                eat(1)
                st = 0
                if pk() == 31
                    eat(31)
                    st = pn()
                    eat(1)
                end
                sty = push!(sty, st)
                gaps()
            end
            if pn() != kw_stop
                lx_bad()
            end
            eat(1)
            lv_add(lstructs, [sx, sf, sty])
        elseif sn == kw_rule
            sh = expr()
            eat(12)
            sg = goal_or()
            sh = lc_term(sh, 0)
            sg = lc_goal(sg, 0)
            lv_add(lclauses, [sh, sg])
        elseif (sn == kw_println) || (sn == kw_print)
            eat(6)
            se = expr()
            eat(7)
            sv = leval(se)
            ss = lshow(sv, false)
            if sn == kw_println
                println(ss)
            else
                print(ss)
            end
        elseif pk() == 6
            eat(6)
            sp = []
            if pk() != 7
                sp = push!(sp, pn())
                eat(1)
                while pk() == 10
                    eat(10)
                    sp = push!(sp, pn())
                    eat(1)
                end
            end
            eat(7)
            if sbk
                gaps()
                if (pk() == 1) && (pn() == kw_ret)
                    eat(1)
                end
            else
                eat(13)
            end
            sg = goal_or()
            if sbk
                gaps()
                if pn() != kw_stop
                    lx_bad()
                end
                eat(1)
            end
            shargs = []
            si = 0
            while si < length(sp)
                shargs = push!(shargs, [1, get(sp, si)])
                si = si + 1
            end
            sg = lf_goal(sg, sp)
            lv_add(lclauses, [[5, sn, shargs], sg])
        else
            eat(13)
            se = expr()
            sv = leval(se)
            le_set(sn, sv)
        end
        if (pk() != 11) && (pk() != 0)
            lx_bad()
        end
        gaps()
    end
    0
end
