package main
import "core:strconv"
import "core:strings"
import "core:unicode/utf8"

float_to_cstring :: proc(f : f32, buffer : []u8) -> cstring {
    return strings.unsafe_string_to_cstring(
        strconv.ftoa(buffer, cast(f64)f, 'f', 4, 32)
    )
}

rune_is_ascii :: proc(r : rune) -> bool {
    return r < 128
}

cstring_split_at :: proc(
    cstr : cstring,
    n : int,
    allocator := context.allocator,
) -> (cstring, cstring) {
    length := len(cstr)
    if n > length { return cstr, "" }
    if n <= 0 { return "", cstr }

    str := strings.string_from_ptr(transmute([^]u8)cstr, length)
    return strings.clone_to_cstring(str[0:n]),
           strings.clone_to_cstring(str[n:length])
}

cstring_insert_at :: proc(
    cstr : cstring,
    n : int,
    insert : rune,
    allocator := context.allocator,
) -> cstring {
    length := len(cstr)
    char := [1]rune{insert}
    char_string := utf8.runes_to_string(char[:])
    cstr_insert := strings.unsafe_string_to_cstring(char_string)
    if n > length { return cstring_concat(cstr, cstr_insert) }
    if n <= 0 { return cstring_concat(cstr_insert, cstr) }

    front, back := cstring_split_at(cstr, n, allocator)
    return cstring_concat(cstring_concat(front, cstr_insert), back)
}

cstring_remove_at :: proc(
    cstr : cstring,
    n : int,
    allocator := context.allocator,
) -> cstring {
    length := len(cstr)
    if n >= length || n < 0 { return cstr }

    front, b := cstring_split_at(cstr, n, allocator)
    f, back := cstring_split_at(cstr, n + 1, allocator)
    free(cast(rawptr)b, allocator)
    free(cast(rawptr)f, allocator)
    return cstring_concat(front, back)
}

cstring_concat :: proc(
    a : cstring,
    b : cstring,
) -> cstring {
    s := [?]string{string(a), string(b)}
    concatenated := strings.concatenate(s[:])
    return strings.unsafe_string_to_cstring(concatenated)
}
