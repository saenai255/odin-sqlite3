package addons

import sqlite3 ".."
import "base:runtime"
import "core:c"
import "core:fmt"
import "core:log"
import "core:mem"
import "core:reflect"
import "core:slice"
import "core:strconv"
import "core:strings"
import "core:text/regex"

Runtime_Config :: struct {
	extra_runtime_checks: bool,
	log_level:            Maybe(log.Level),
}

config: Runtime_Config

Query_Error :: Maybe(string)

Query_Param_Value :: union {
	i32,
	i64,
	f64,
	[]byte,
	bool,
	string,
}

Query_Param :: struct {
	index: int,
	value: Query_Param_Value,
}

query :: proc(
	db: ^sqlite3.Connection,
	out: ^[dynamic]$T,
	sql: string,
	params: []Query_Param = {},
	location := #caller_location,
) -> sqlite3.Result_Code {
	stmt: ^sqlite3.Statement

	prepare(db, &stmt, sql, params, location) or_return
	return read_all_rows(stmt, out)
}

// Allocates. Make sure to free results even when the return value is not .Ok
@(require_results)
read_all_rows :: proc(stmt: ^sqlite3.Statement, out: ^[dynamic]$T) -> sqlite3.Result_Code {
	fields, err := get_type_fields(T)
	if err != nil {
		log.error(err)
		return .Internal
	}

	defer delete_field_types(fields)

	field_map: map[string]^Field_Type
	defer delete(field_map)
	for &field in fields {
		field_map[field.tag] = &field
	}

	defer sqlite3.finalize(stmt)
	for sqlite3.step(stmt) == .Row {
		item: T
		cols := sqlite3.column_count(stmt)
		for i in 0 ..< cols {
			column := strings.clone_from(sqlite3.column_name(stmt, i))
			defer delete(column)

			field_type, ok := field_map[column]
			if !ok {
				log.errorf("could not find tag {} in {}", column, typeid_of(T))
				return .Internal
			}

			if err := write_struct_field_from_statement(&item, field_type, stmt, c.int(i));
			   err != nil {
				log.error(err)
				free_query_error(err)
				return .Internal
			}
		}

		append(out, item)
	}

	return .Ok
}

@(require_results)
execute :: proc(
	db: ^sqlite3.Connection,
	sql: string,
	params: []Query_Param = {},
	location := #caller_location,
) -> sqlite3.Result_Code {
	stmt: ^sqlite3.Statement
	prepare(db, &stmt, sql, params, location) or_return
	defer sqlite3.finalize(stmt)
	for sqlite3.step(stmt) == .Row {
		// consume all rows
	}

	return .Ok
}

@(require_results)
prepare :: proc(
	db: ^sqlite3.Connection,
	stmt: ^^sqlite3.Statement,
	sql: string,
	params: []Query_Param = {},
	location := #caller_location,
) -> sqlite3.Result_Code {
	c_sql := strings.clone_to_cstring(sql)
	defer delete(c_sql)

	sqlite3.prepare_v2(db, c_sql, c.int(len(c_sql)), stmt, nil) or_return

	for &param in params {
		idx := c.int(param.index)

		if param.value == nil {
			sqlite3.bind_null(stmt^, idx) or_return
		} else if v, ok := param.value.(i32); ok {
			sqlite3.bind_int(stmt^, idx, c.int(v)) or_return
		} else if v, ok := param.value.(i64); ok {
			sqlite3.bind_int64(stmt^, idx, c.int64_t(v)) or_return
		} else if v, ok := param.value.([]byte); ok {
			sqlite3.bind_blob64(stmt^, idx, slice.as_ptr(v), c.int64_t(len(v)), {behaviour = .Static}) or_return
		} else if v, ok := param.value.(bool); ok {
			sqlite3.bind_int(stmt^, idx, c.int(v ? 1 : 0)) or_return
		} else if v, ok := param.value.(string); ok {
			// Sqlite treats our parameter as a "cstring" if we pass a negative length.
			// Explicitly it's just a slice.
			// https://sqlite.org/c3ref/bind_blob.html.
			cstr := strings.unsafe_string_to_cstring(v)
			sqlite3.bind_text(stmt^, idx, cstr, c.int(len(v)), {behaviour = .Static}) or_return
		} else {
			log.errorf("unhandled parameter type {}", param.value)
			return .Internal
		}

	}

	do_log("SQL: {}", sqlite3.expanded_sql(stmt^), location = location)
	return .Ok
}
@(private)
do_log :: #force_inline proc(format_str: string, args: ..any, location := #caller_location) {
	level, ok := config.log_level.?
	if !ok do return

	if context.logger.procedure != log.nil_logger_proc {
		log.logf(level, format_str, ..args, location = location)
		return
	}

	logger := log.create_console_logger()
	defer log.destroy_console_logger(logger)
	{
		context.logger = logger
		log.logf(level, format_str, ..args, location = location)
	}
}

@(private)
free_query_error :: #force_inline proc(err: Query_Error) {
	delete(err.(string), context.temp_allocator)
}

@(private)
@(require_results)
write_struct_field_from_statement :: proc(
	obj: ^$T,
	field: ^Field_Type,
	stmt: ^sqlite3.Statement,
	col_idx: c.int,
) -> Query_Error {
	switch field.type.id {
	case typeid_of(string):
		value := strings.clone_from(sqlite3.column_text(stmt, col_idx))
		write_struct_field(obj, field^, value) or_return

	case typeid_of(bool):
		value := sqlite3.column_int(stmt, col_idx) != 0
		write_struct_field(obj, field^, value) or_return

	case typeid_of(int):
		value := int(sqlite3.column_int(stmt, col_idx))
		write_struct_field(obj, field^, value) or_return

	case typeid_of(uint):
		value := uint(sqlite3.column_int(stmt, col_idx))
		write_struct_field(obj, field^, value) or_return

	case typeid_of(i8):
		value := i8(sqlite3.column_int(stmt, col_idx))
		write_struct_field(obj, field^, value) or_return

	case typeid_of(u8):
		value := u8(sqlite3.column_int(stmt, col_idx))
		write_struct_field(obj, field^, value) or_return

	case typeid_of(i16):
		value := i16(sqlite3.column_int(stmt, col_idx))
		write_struct_field(obj, field^, value) or_return

	case typeid_of(u16):
		value := u16(sqlite3.column_int(stmt, col_idx))
		write_struct_field(obj, field^, value) or_return

	case typeid_of(i32):
		value := i32(sqlite3.column_int(stmt, col_idx))
		write_struct_field(obj, field^, value) or_return

	case typeid_of(u32):
		value := u32(sqlite3.column_int(stmt, col_idx))
		write_struct_field(obj, field^, value) or_return

	case typeid_of(i64):
		value := i64(sqlite3.column_int64(stmt, col_idx))
		write_struct_field(obj, field^, value) or_return

	case typeid_of(u64):
		value := u64(sqlite3.column_int64(stmt, col_idx))
		write_struct_field(obj, field^, value) or_return

	case:
		if reflect.is_enum(field.type) {
			enum_values := reflect.enum_field_values(field.type.id)

			value := i64(sqlite3.column_int64(stmt, col_idx))

			if config.extra_runtime_checks {
				found := false

				for it in enum_values {
					if i64(it) == value {
						found = true
						break
					}
				}

				if !found {
					return fmt.tprintf(
						"expected to find enum value {} in {}",
						value,
						field.type.id,
					)
				}
			}

			write_struct_field(obj, field^, value) or_return
		} else {
			return fmt.tprintf("unhandled data type {}", field.type.id)
		}
	}

	return nil
}
