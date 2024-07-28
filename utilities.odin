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
    cstr : cstring, n : int,
    allocator := context.allocator,
) -> (cstring, cstring) {
    if n > len(cstr) { return cstr, "" }
    if n <= 0 { return "", cstr }

    len := len(cstr)
    str := strings.string_from_ptr(transmute([^]u8)cstr, len)
    return strings.clone_to_cstring(str[0:n], allocator),
           strings.clone_to_cstring(str[n:len], allocator)
}

cstring_insert_at :: proc(
    cstr : cstring, n : int,
    insert : rune,
    allocator := context.allocator,
) -> cstring {
    char := [1]rune{insert}
    char_string := utf8.runes_to_string(char[:], context.allocator)
    defer free(raw_data(char_string), context.allocator)

    cstr_insert := strings.unsafe_string_to_cstring(char_string)
    if n > len(cstr) { return cstring_concat(cstr, cstr_insert, allocator) }
    if n <= 0 { return cstring_concat(cstr_insert, cstr, allocator) }

    front, back := cstring_split_at(cstr, n, context.allocator)
    front_concat := cstring_concat(front, cstr_insert, context.allocator)
    return cstring_concat(front_concat, back, allocator)
}

cstring_remove_at :: proc(
    cstr : cstring,
    n : int,
    allocator := context.allocator,
) -> cstring {
    if n >= len(cstr) || n < 0 { return cstr }
    if n == 0 {
        _, back := cstring_split_at(cstr, 1, context.allocator) 
        return back
    }

    front, b := cstring_split_at(cstr, n, context.allocator)
    defer free(cast(rawptr)front, context.allocator)
    defer free(cast(rawptr)b, context.allocator)

    f, back := cstring_split_at(cstr, n + 1, context.allocator)
    defer free(cast(rawptr)f, context.allocator)
    defer free(cast(rawptr)back, context.allocator)

    return cstring_concat(front, back, allocator)
}

cstring_concat :: proc(
    a : cstring,
    b : cstring,
    allocator := context.allocator
) -> cstring {
    s := [?]string{string(a), string(b)}
    return strings.unsafe_string_to_cstring(
        strings.concatenate(s[:], allocator)
    )
}
