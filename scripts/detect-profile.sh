#!/bin/sh
# Lexical profile selection only; never executes or retries the input program.
# Byte scanning ignores strings, escaped quotes, line and nested block comments.
set -u
[ "$#" = 1 ] && [ -r "$1" ] || exit 2
od -An -v -tu1 "$1" | {
    state=code; prev=0; word=; eligible=1; pending=; depth=0; escape=0
    while IFS= read -r row; do
        for byte in $row; do
            case $state in
                string)
                    if [ "$escape" = 1 ]; then escape=0
                    elif [ "$byte" = 92 ]; then escape=1
                    elif [ "$byte" = 34 ]; then state=code; prev=34
                    fi
                    continue ;;
                hash)
                    if [ "$byte" = 61 ]; then state=block; depth=1; prev=0
                    elif [ "$byte" = 10 ]; then state=code; prev=10
                    else state=line
                    fi
                    continue ;;
                line)
                    [ "$byte" != 10 ] || { state=code; prev=10; }
                    continue ;;
                block)
                    if [ "$prev" = 35 ] && [ "$byte" = 61 ]; then
                        depth=$((depth + 1)); prev=0
                    elif [ "$prev" = 61 ] && [ "$byte" = 35 ]; then
                        depth=$((depth - 1)); prev=0
                        [ "$depth" != 0 ] || state=code
                    else prev=$byte
                    fi
                    continue ;;
            esac
            # A candidate keyword must be followed by a goal/name, not '='.
            if [ -n "$pending" ]; then
                case $byte in
                    32|9|13) continue ;;
                    10|59) pending= ;;
                    *)
                        if { [ "$byte" -ge 65 ] && [ "$byte" -le 90 ]; } ||
                           { [ "$byte" -ge 97 ] && [ "$byte" -le 122 ]; } ||
                           [ "$byte" = 95 ] ||
                           { [ "$pending" = solve ] && { [ "$byte" = 63 ] || [ "$byte" = 33 ] || [ "$byte" = 40 ]; }; }; then
                            printf 'logic\n'; exit 0
                        fi
                        pending= ;;
                esac
            fi
            if { [ "$byte" -ge 65 ] && [ "$byte" -le 90 ]; } ||
               { [ "$byte" -ge 97 ] && [ "$byte" -le 122 ]; } ||
               { [ "$byte" -ge 48 ] && [ "$byte" -le 57 ]; } ||
               [ "$byte" = 95 ] || [ "$byte" = 33 ]; then
                if [ -z "$word" ]; then
                    eligible=1
                    case $prev in 58|46) eligible=0 ;; esac
                fi
                word=${word}_$byte
                [ "${#word}" -le 40 ] || word=_other
            else
                if [ "$eligible" = 1 ]; then
                    case $word in
                        _102_97_99_116|_114_117_108_101|_115_116_114_117_99_116) pending=name ;;
                        _115_111_108_118_101) pending=solve ;;
                    esac
                fi
                word=
                # Process this delimiter again as the candidate's first byte.
                case $byte in
                    32|9|13) : ;;
                    40) if [ "$pending" = solve ]; then printf 'logic\n'; exit 0; fi; pending= ;;
                    35) state=hash; pending= ;;
                    34) state=string; pending= ;;
                    *) pending= ;;
                esac
            fi
            prev=$byte
        done
    done
    printf 'core\n'
}
