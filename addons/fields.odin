package addons

import "core:fmt"
import "core:reflect"
import "core:testing"

Field_Error :: Maybe(string)

@(private)
Field_Type :: struct {
	name:   string,
	type:   ^reflect.Type_Info,
	offset: int,
}

@(private)
write_struct_field :: proc(obj: ^$T, field: Field_Type, value: $E) -> Field_Error {
	if !(size_of(field.type.id) == size_of(E) || field.type.id == typeid_of(E)) {
		return fmt.tprintf(
			"given field {}.{} ({}) is not the same size as given value {}. {} != {}",
			typeid_of(T),
			field.name,
			field.type.id,
			typeid_of(E),
			size_of(field.type.id),
			size_of(E),
		)
	}

	obj_bytes := reflect.as_bytes(obj^)
	value_bytes := reflect.as_bytes(value)
	for i in 0 ..< len(value_bytes) {
		obj_bytes[int(field.offset) + i] = value_bytes[i]
	}

	return nil
}

@(test)
write_struct_field_test :: proc(t: ^testing.T) {
	S :: struct($T: typeid) {
		padding1: [13]u8 `sqlite:"Padding1"`,
		value:    T `sqlite:"Value"`,
		padding2: [5]u8 `sqlite:"Padding2"`,
	}

	test_using_type :: proc(t: ^testing.T, value: $T) {
		S1 :: S(T)
		fields := get_type_fields(S1)
		defer delete(fields)

		value_field := fields[1]
		obj: S1

		err := write_struct_field(&obj, value_field, value)
		testing.expect(t, err == nil)
		testing.expect_value(t, obj.value, value)

		// neighbours are unchanged
		for b in obj.padding1 {
			testing.expect(t, b == 0)
		}

		// neighbours are unchanged
		for b in obj.padding2 {
			testing.expect(t, b == 0)
		}
	}

	test_using_type(t, u8(100))
	test_using_type(t, i8(100))
	test_using_type(t, true)
	test_using_type(t, i16(100))
	test_using_type(t, u16(100))
	test_using_type(t, i32(100))
	test_using_type(t, u32(100))
	test_using_type(t, i64(100))
	test_using_type(t, u64(100))
	test_using_type(t, "hello")
}

@(private)
@(require_results)
get_type_fields :: proc($T: typeid) -> []Field_Type {
	out := make([]Field_Type, reflect.struct_field_count(T))
	for i in 0 ..< reflect.struct_field_count(T) {
		field := reflect.struct_field_at(T, i)
		name  := reflect.struct_tag_lookup(field.tag, "sqlite") or_else field.name

		out[i] = {
			name   = name,
			type   = field.type,
			offset = int(field.offset),
		}
	}

	return out[:]
}


@(test)
get_type_fields_test__all_ok :: proc(t: ^testing.T) {
	S :: struct {
		a: int `sqlite:"Foo"`,
		b: bool `sqlite:"Bar"`,
		c: string `sqlite:"Foobar"`,
	}

	fields := get_type_fields(S)
	defer delete(fields)

	testing.expect(t, fields[0].name == "Foo")
	testing.expect(t, fields[0].type.id == typeid_of(int))

	testing.expect(t, fields[1].name == "Bar")
	testing.expect(t, fields[1].type.id == typeid_of(bool))

	testing.expect(t, fields[2].name == "Foobar")
	testing.expect(t, fields[2].type.id == typeid_of(string))
}


@(test)
get_type_fields_test__missing_tag :: proc(t: ^testing.T) {
	S :: struct {
		a: int `sqlite:"Foo"`,
		b: bool,
		c: string `sqlite:"Foobar"`,
	}

	fields := get_type_fields(S)
	defer delete(fields)

	testing.expect(t, fields[0].name == "Foo")
	testing.expect(t, fields[0].type.id == typeid_of(int))

	testing.expect(t, fields[1].name == "b")
	testing.expect(t, fields[1].type.id == typeid_of(bool))

	testing.expect(t, fields[2].name == "Foobar")
	testing.expect(t, fields[2].type.id == typeid_of(string))
}
