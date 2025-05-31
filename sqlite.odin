package sqlite3

import "core:c"

Connection :: rawptr
Backup :: rawptr
Statement :: rawptr
Blob :: rawptr

@(private)
USE_DYNAMIC_LIB :: #config(SQLITE3_DYNAMIC_LIB, false)
@(private)
USE_SYSTEM_LIB :: #config(SQLITE3_SYSTEM_LIB, true)
@(private)
USE_SQLCIPHER :: #config(SQLITE3_USE_SQLCIPHER, false)

when ODIN_OS == .Windows {
	when USE_SYSTEM_LIB {
		when USE_DYNAMIC_LIB {
			when USE_SQLCIPHER {
				foreign import sqlite "system:libsqlcipher.dll"
			} else {
				foreign import sqlite "system:libsqlite3.dll"
			}
		} else {
			when USE_SQLCIPHER {
				foreign import sqlite "system:libsqlcipher.lib"
			} else {
				foreign import sqlite "system:libsqlite3.lib"
			}
		}
	} else {
		when USE_DYNAMIC_LIB {
			when USE_SQLCIPHER {
				foreign import sqlite "libsqlcipher.dll"
			} else {
				foreign import sqlite "libsqlite3.dll"
			}
		} else {
			when USE_SQLCIPHER {
				foreign import sqlite "libsqlcipher.lib"
			} else {
				foreign import sqlite "libsqlite3.lib"
			}
		}
	}
} else when ODIN_OS == .Darwin {
	when USE_SYSTEM_LIB {
		when USE_DYNAMIC_LIB {
			when USE_SQLCIPHER {
				foreign import sqlite "system:libsqlcipher.dylib"
			} else {
				foreign import sqlite "system:libsqlite3.dylib"
			}
		} else {
			when USE_SQLCIPHER {
				foreign import sqlite "system:libsqlcipher.a"
			} else {
				foreign import sqlite "system:libsqlite3.a"
			}
		}
	} else {
		when USE_DYNAMIC_LIB {
			when USE_SQLCIPHER {
				foreign import sqlite "libsqlcipher.dylib"
			} else {
				foreign import sqlite "libsqlite3.dylib"
			}
		} else {
			when USE_SQLCIPHER {
				foreign import sqlite "libsqlcipher.a"
			} else {
				foreign import sqlite "libsqlite3.a"
			}
		}
	}
} else when ODIN_OS == .Linux {
	when USE_SYSTEM_LIB {
		when USE_DYNAMIC_LIB {
			when USE_SQLCIPHER {
				foreign import sqlite "system:libsqlcipher.so"
			} else {
				foreign import sqlite "system:libsqlite3.so.0"
			}
		} else {
			when USE_SQLCIPHER {
				foreign import sqlite "system:libsqlcipher.a"
			} else {
				foreign import sqlite "system:libsqlite3.a"
			}
		}
	} else {
		when USE_DYNAMIC_LIB {
			when USE_SQLCIPHER {
				foreign import sqlite "libsqlcipher.so"
			} else {
				foreign import sqlite "libsqlite3.so"
			}
		} else {
			when USE_SQLCIPHER {
				foreign import sqlite "libsqlcipher.a"
			} else {
				foreign import sqlite "libsqlite3.a"
			}
		}
	}
}

Config_Option :: enum (c.int) {
	Single_Thread       = 1,
	Multi_Thread        = 2,
	Serialized          = 3,
	Malloc              = 4,
	Get_Malloc          = 5,
	Scratch             = 6,
	Page_Cache          = 7,
	Heap                = 8,
	Mem_Status          = 9,
	Mutex               = 10,
	Get_Mutex           = 11,
	Lookaside           = 13,
	PCache              = 14,
	Get_PCache          = 15,
	Log                 = 16,
	Uri                 = 17,
	PCache2             = 18,
	Get_PCache2         = 19,
	Covering_Index_Scan = 20,
	SqlLog              = 21,
	Mmap_Size           = 22,
	Win32_Heapsize      = 23,
	PCache_Hdrsz        = 24,
	Pmasz               = 25,
	StmtJrnl_Spill      = 26,
	Small_Malloc        = 27,
	SorterRef_Size      = 28,
	Memdb_Maxsize       = 29,
	Rowid_In_View       = 30,
}

Open_Flags :: enum {
	Read_Only = 0,
	Read_Write,
	Create,
	Delete_On_Close,
	Exclusive,
	Autoproxy,
	URI,
	Memory,
	Main_DB,
	Temp_DB,
	Transient_DB,
	Main_Journal,
	Temp_Journal,
	Subjournal,
	Super_Journal,
	No_Mutex,
	Full_Mutex,
	Shared_Cache,
	Private_Cache,
	WAL,
}

Result_Code :: enum (c.int) {
	Ok                      = 0,
	Error                   = 1,
	Internal                = 2,
	Perm                    = 3,
	Abort                   = 4,
	Busy                    = 5,
	Locked                  = 6,
	NoMem                   = 7,
	ReadOnly                = 8,
	Interrupt               = 9,
	IoErr                   = 10,
	Corrupt                 = 11,
	NotFound                = 12,
	Full                    = 13,
	CantOpen                = 14,
	Protocol                = 15,
	Empty                   = 16,
	Schema                  = 17,
	TooBig                  = 18,
	Constraint              = 19,
	Mismatch                = 20,
	Misuse                  = 21,
	NoLfs                   = 22,
	Auth                    = 23,
	Format                  = 24,
	Range                   = 25,
	NotA_Db                 = 26,
	Notice                  = 27,
	Warning                 = 28,
	Row                     = 100,
	Done                    = 101,
	Ok_Load_Permanently     = 256,
	Error_Missing_CollSeq   = 257,
	Busy_Recovery           = 261,
	Locked_SharedCache      = 262,
	ReadOnly_Recovery       = 264,
	IoErr_Read              = 266,
	Corrupt_Vtab            = 267,
	CantOpen_NoTempDir      = 270,
	Constraint_Check        = 275,
	Auth_User               = 279,
	Notice_Recover_Wal      = 283,
	Warning_AutoIndex       = 284,
	Error_Retry             = 513,
	Abort_Rollback          = 516,
	Busy_Snapshot           = 517,
	Locked_Vtab             = 518,
	ReadOnly_CantLock       = 520,
	IoErr_Short_Read        = 522,
	Corrupt_Sequence        = 523,
	CantOpen_IsDir          = 526,
	Constraint_CommitHook   = 531,
	Notice_Recover_Rollback = 539,
	Error_Snapshot          = 769,
	Busy_Timeout            = 773,
	ReadOnly_Rollback       = 776,
	IoErr_Write             = 778,
	Corrupt_Index           = 779,
	CantOpen_FullPath       = 782,
	Constraint_ForeignKey   = 787,
	ReadOnly_DbMoved        = 1032,
	IoErr_FSync             = 1034,
	CantOpen_ConvPath       = 1038,
	Constraint_Function     = 1043,
	ReadOnly_CantInit       = 1288,
	IoErr_Dir_FSync         = 1290,
	CantOpen_DirtyWal       = 1294,
	Constraint_NotNull      = 1299,
	ReadOnly_Directory      = 1544,
	IoErr_Truncate          = 1546,
	CantOpen_Symlink        = 1550,
	Constraint_PrimaryKey   = 1555,
	IoErr_FStat             = 1802,
	Constraint_Trigger      = 1811,
	IoErr_Unlock            = 2058,
	Constraint_Unique       = 2067,
	IoErr_RdLock            = 2314,
	Constraint_Vtab         = 2323,
	IoErr_Delete            = 2570,
	Constraint_RowId        = 2579,
	IoErr_Blocked           = 2826,
	Constraint_Pinned       = 2835,
	IoErr_NoMem             = 3082,
	Constraint_DataType     = 3091,
	IoErr_Access            = 3338,
	IoErr_CheckReservedLock = 3594,
	IoErr_Lock              = 3850,
	IoErr_Close             = 4106,
	IoErr_Dir_Close         = 4362,
	IoErr_ShmOpen           = 4618,
	IoErr_ShmSize           = 4874,
	IoErr_ShmLock           = 5130,
	IoErr_ShmMap            = 5386,
	IoErr_Seek              = 5642,
	IoErr_Delete_NoEnt      = 5898,
	IoErr_MMap              = 6154,
	IoErr_GetTempPath       = 6410,
	IoErr_ConvPath          = 6666,
	IoErr_VNode             = 6922,
	IoErr_Auth              = 7178,
	IoErr_Begin_Atomic      = 7434,
	IoErr_Commit_Atomic     = 7690,
	IoErr_Rollback_Atomic   = 7946,
	IoErr_Data              = 8202,
	IoErr_CorruptFS         = 8458,
}

DataType :: enum(c.int) {
	INTEGER = 1,
	FLOAT  = 2,
	TEXT   = 3,
	BLOB   = 4,
	NULL   = 5,
}

@(link_prefix = "sqlite3_")
foreign sqlite {
	free :: proc "c" (ptr: rawptr) ---
	open :: proc "c" (filename: cstring, db: ^^Connection) -> Result_Code ---
	open16 :: proc "c" (filename: cstring, db: ^^Connection) -> Result_Code ---
	open_v2 :: proc "c" (filename: cstring, db: ^^Connection, flags: bit_set[Open_Flags]={}, z_vfs: cstring = nil) -> Result_Code ---
	close :: proc "c" (db: ^Connection) -> Result_Code ---
	close_v2 :: proc "c" (db: ^Connection) -> Result_Code ---
	prepare :: proc "c" (db: ^Connection, sql: cstring, n_bytes: c.int, statement: ^^Statement, tail: ^^cstring = nil) -> Result_Code ---
	prepare_v2 :: proc "c" (db: ^Connection, sql: cstring, n_bytes: c.int, statement: ^^Statement, tail: ^^cstring = nil) -> Result_Code ---
	step :: proc "c" (statement: ^Statement) -> Result_Code ---
	finalize :: proc "c" (statememt: ^Statement) -> Result_Code ---
	exec :: proc "c" (db: ^Connection, sql: cstring, cb: proc "c" (ctx: rawptr, argc: c.int, argv: [^]cstring, col_names: [^]cstring) -> c.int = nil, ctx: rawptr = nil, err: ^cstring = nil) -> Result_Code ---
	changes :: proc "c" (db: ^Connection) -> c.int ---
	changes64 :: proc "c" (db: ^Connection) -> c.int64_t ---
	auto_extension :: proc "c" (x_entry_point: proc "c" ()) -> Result_Code ---
	cancel_auto_extension :: proc "c" (x_entry_point: proc "c" ()) -> Result_Code ---
	backup :: proc "c" (dest: ^Connection, dest_name: cstring, source: ^Connection, source_name: cstring) -> ^Backup ---
	backup_step :: proc "c" (backup: ^Backup, n_page: c.int) -> c.int ---
	backup_finish :: proc "c" (backup: ^Backup) -> Result_Code ---
	backup_remaining :: proc "c" (backup: ^Backup) -> c.int ---
	backup_pagecount :: proc "c" (backup: ^Backup) -> c.int ---
	bind_blob :: proc "c" (statement: ^Statement, param_idx: c.int, param_value: [^]byte, param_len: c.int, free: proc(it: rawptr)) -> Result_Code ---
	bind_blob64 :: proc "c" (statement: ^Statement, param_idx: c.int, param_value: [^]byte, param_len: c.int64_t, free: proc(it: rawptr)) -> Result_Code ---
	bind_double :: proc "c" (statement: ^Statement, param_idx: c.int, param_value: c.double) -> Result_Code ---
	bind_int :: proc "c" (statement: ^Statement, param_idx: c.int, param_value: c.int) -> Result_Code ---
	bind_int64 :: proc "c" (statement: ^Statement, param_idx: c.int, param_value: c.int64_t) -> Result_Code ---
	bind_null :: proc "c" (statement: ^Statement, param_idx: c.int) -> Result_Code ---
	bind_text :: proc "c" (statement: ^Statement, param_idx: c.int, param_value: cstring, param_len: c.int, free: proc(it: rawptr)) -> Result_Code ---
	bind_text16 :: proc "c" (statement: ^Statement, param_idx: c.int, param_value: cstring, param_len: c.int, free: proc(it: rawptr)) -> Result_Code ---
	bind_text64 :: proc "c" (statement: ^Statement, param_idx: c.int, param_value: cstring, param_len: c.int64_t, free: proc(it: rawptr), encoding: c.uchar) -> Result_Code ---
	bind_zeroblob :: proc "c" (statement: ^Statement, param_idx: c.int, len: c.int) -> Result_Code ---
	bind_zeroblob64 :: proc "c" (statement: ^Statement, param_idx: c.int, len: c.int64_t) -> Result_Code ---
	bind_parameter_count :: proc "c" (statement: ^Statement) -> c.int ---
	bind_parameter_index :: proc "c" (statement: ^Statement, name: cstring) -> c.int ---
	bind_parameter_name :: proc "c" (statement: ^Statement, param_idx: c.int) -> cstring ---
	blob_bytes :: proc "c" (blob: ^Blob) -> c.int ---
	blob_close :: proc "c" (blob: ^Blob) -> Result_Code ---
	blob_open :: proc "c" (db: ^Connection, database_name: cstring, table: cstring, column: cstring, row_idx: c.int64_t, flags: bit_set[Open_Flags]={}, blob: ^^Blob) -> Result_Code ---
	blob_read :: proc "c" (blob: ^Blob, dest: rawptr, n_bytes: c.int, n_bytes_offset: c.int) -> Result_Code ---
	blob_write :: proc "c" (blob: ^Blob, source: rawptr, n_bytes: c.int, n_bytes_offset: c.int) -> Result_Code ---
	blob_reopen :: proc "c" (blob: ^Blob, row_id: c.int64_t) -> Result_Code ---
	busy_handler :: proc "c" (db: ^Connection, handler: proc "c" (ctx: rawptr, attempt: c.int) -> Result_Code, ctx: rawptr) -> Result_Code ---
	busy_timeout :: proc "c" (db: ^Connection, ms: c.int) -> Result_Code ---
	@(require_results)
	column_database_name :: proc "c" (statement: ^Statement, col_idx: c.int) -> cstring ---
	@(require_results)
	column_database_name16 :: proc "c" (statement: ^Statement, col_idx: c.int) -> cstring ---
	@(require_results)
	column_table_name :: proc "c" (statement: ^Statement, col_idx: c.int) -> cstring ---
	@(require_results)
	column_table_name16 :: proc "c" (statement: ^Statement, col_idx: c.int) -> cstring ---
	@(require_results)
	column_origin_name :: proc "c" (statement: ^Statement, col_idx: c.int) -> cstring ---
	@(require_results)
	column_origin_name16 :: proc "c" (statement: ^Statement, col_idx: c.int) -> cstring ---
	@(require_results)
	column_decltype :: proc "c" (statement: ^Statement, col_idx: c.int) -> cstring ---
	@(require_results)
	column_decltype16 :: proc "c" (statement: ^Statement, col_idx: c.int) -> cstring ---
	@(require_results)
	column_text :: proc "c" (statement: ^Statement, col_idx: c.int) -> cstring ---
	column_blob :: proc "c" (statement: ^Statement, col_idx: c.int) -> rawptr ---
	column_double :: proc "c" (statement: ^Statement, col_idx: c.int) -> c.double ---
	column_int :: proc "c" (statement: ^Statement, col_idx: c.int) -> c.int ---
	column_int64 :: proc "c" (statement: ^Statement, col_idx: c.int) -> c.int64_t ---
	column_bytes :: proc "c" (statement: ^Statement, col_idx: c.int) -> c.int ---
	column_bytes16 :: proc "c" (statement: ^Statement, col_idx: c.int) -> c.int ---
	column_type :: proc "c" (statement: ^Statement, col_idx: c.int) -> DataType ---
	column_count :: proc "c" (statement: ^Statement) -> c.int ---
	column_name :: proc "c" (statement: ^Statement, col_idx: c.int) -> cstring ---
	commit_hook :: proc "c" (db: ^Connection, cb: proc "c" (ctx: rawptr) -> Result_Code, ctx: rawptr) -> rawptr ---
	rollback_hook :: proc "c" (db: ^Connection, cb: proc "c" (ctx: rawptr) -> Result_Code, ctx: rawptr) -> rawptr ---
	compileoption_used :: proc "c" (opt_name: cstring) -> c.int ---
	@(require_results)
	compileoption_get :: proc "c" (n: c.int) -> cstring ---
	complete :: proc "c" (sql: cstring) -> c.int ---
	complete16 :: proc "c" (sql: cstring) -> c.int ---
	//  TODO: this function should also have varargs
	config :: proc "c" (option: Config_Option) -> Result_Code ---
	sql :: proc "c" (statement: ^Statement) -> cstring ---
	expanded_sql :: proc "c" (statement: ^Statement) -> cstring ---

	@(require_results)
	errcode :: proc "c" (db: ^Connection) -> Result_Code ---
	@(require_results)
	extended_errcode :: proc "c" (db: ^Connection) -> Result_Code ---
	errmsg :: proc "c" (db: ^Connection) -> cstring ---
	errmsg16 :: proc "c" (db: ^Connection) -> cstring ---
	errstr :: proc "c" (code: Result_Code) -> cstring ---

	// Export SQLCipher-specific functions conditionally.
	when USE_SQLCIPHER {
		key :: proc "c" (db: ^Connection, key: rawptr, nKey: c.int) -> c.int ---
		key_v2 :: proc "c" (db: ^Connection, zDbName: cstring, key: rawptr, nKey: c.int) -> c.int ---
		rekey :: proc "c" (db: ^Connection, key: rawptr, nKey: c.int) -> c.int ---
		rekey_v2 :: proc "c" (db: ^Connection, zDbName: cstring, key: rawptr, nKey: c.int) -> c.int ---
	}
}
