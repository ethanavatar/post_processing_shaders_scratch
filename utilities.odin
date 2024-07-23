package main
import "core:strconv"
import "core:strings"

float_to_cstring :: proc(f : f32, buffer : []u8) -> cstring {
    return strings.unsafe_string_to_cstring(
        strconv.ftoa(buffer, cast(f64)f, 'f', 4, 32)
    )
}
