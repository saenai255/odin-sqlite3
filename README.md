# Odin SQLite3 Bindings

This is a set of Odin bindings to the SQLite3 C API, providing direct access to SQLite's functionality while also including a more Odin-like "addon" package for convenience.

## Features

- **Base Package**: Covers roughly 80% of all SQLite3 functions. These functions are used in the same way as the original C API.
- **Addon Package**: Provides a higher-level interface with four convenience functions for working with SQLite in a more idiomatic Odin fashion.

## Disclaimer

I have only tested the most straightforward use cases. While they seem to work fine, not all possible scenarios have been validated. Use at your own discretion and report any issues.

---

## Addon Package Convenience Functions

The addon package simplifies working with SQLite by handling query execution and result parsing using Odin’s reflection capabilities.

### `query`

Executes a SQL statement and returns all results into a dynamic slice of a generic type.

```odin
query :: proc(
    db: ^sqlite3.Connection,
    out: ^[dynamic]$T,
    sql: string,
    params: []Query_Param = {},
    location := #caller_location,
) -> sqlite3.Result_Code
```

- `db`: SQLite database connection.
- `out`: A reference to a dynamic slice that will store the results.
- `sql`: The SQL query string.
- `params`: Optional query parameters.
- Returns: SQLite result code.

### `execute`

Executes a SQL statement without parsing the result.

```odin
execute :: proc(
    db: ^sqlite3.Connection,
    sql: string,
    params: []Query_Param = {},
    location := #caller_location,
) -> sqlite3.Result_Code
```

- Useful for database mutations (INSERT, UPDATE, DELETE, etc.).
- Skips result parsing, making execution faster.

### `prepare`

Prepares a SQL statement with optional parameters for manual result handling.

```odin
prepare :: proc(
    db: ^sqlite3.Connection,
    stmt: ^^sqlite3.Statement,
    sql: string,
    params: []Query_Param = {},
    location := #caller_location,
) -> sqlite3.Result_Code
```

- `stmt`: Pointer to a SQLite statement.
- Use `step` and `finalize` to control execution manually.

### `read_all_rows`

Fetches all results from a prepared statement into a dynamic slice.

```odin
read_all_rows :: proc(stmt: ^sqlite3.Statement, out: ^[dynamic]$T) -> sqlite3.Result_Code
```

- Automatically runs the statement and fills `out` with the results.
- No need to call `finalize` after execution.

## Usage

The base package follows the standard SQLite3 C API conventions, while the addon package provides a more convenient interface for common database operations.

### Defines

You can fine-tune how the library is searched for by setting the following defineables using `odin [command] -define:XYZ=value`.
 - `SQLITE3_DYNAMIC_LIB` - Flag to use the dynamic library instead of the static one. Defaults to `false`.
 - `SQLITE3_SYSTEM_LIB` - Flag to search the library in system defined paths instead of in the working directory. Defaults to `false`.

For more examples and details, refer to the source code.

---

## Examples

### Base Package Example

A simple example using the base SQLite3 API bindings can be found in [`examples/c_api/main.odin`](examples/c_api/main.odin).

Run it using:

```sh
$ odin run examples/c_api
```

<details>
    <summary>Command output</summary>

```console
connected to database

======= query example begin =======

prepared sql: select AlbumId, Title, ArtistId from Album where ArtistId=1 limit 3

albums: [
        Album{
                id = 1,
                title = "For Those About To Rock We Salute You"
,
                artist_id = 1,
        },
        Album{
                id = 4,
                title = "Let There Be Rock",
                artist_id = 1,
        },
]

======= query example end =======

======= exec example begin =======

printing values for row 0
ArtistId = 1
AlbumId = 1
Title = For Those About To Rock We Salute You

printing values for row 1
ArtistId = 2
AlbumId = 2
Title = Balls to the Wall

printing values for row 2
ArtistId = 2
AlbumId = 3
Title = Restless and Wild

printing values for row 3
ArtistId = 1
AlbumId = 4
Title = Let There Be Rock

printing values for row 4
ArtistId = 3
AlbumId = 5
Title = Big Ones

got a total of 5 rows

======= exec example end =======

connection closed
```
</details>

### Addon Package Example

A more Odin-like approach using the addon package can be found in [`examples/easy_api/main.odin`](examples/easy_api/main.odin).

Run it using:

```sh
$ odin run examples/easy_api
```
<details>
    <summary>Command output</summary>

```console
default config: Runtime_Config{
        extra_runtime_checks = false,
        log_level = nil,
}

connected to database

======= query example begin =======

[INFO ] --- [2025-03-07 21:13:16] [main.odin:74:main()] SQL: select AlbumId, Title, ArtistId from Album where ArtistId <= 3 limit 5
albums: [
        Album{
                id = 1,
                title = "For Those About To Rock We Salute You"
,
                artist_id = "AC_DC",
        },
        Album{
                id = 4,
                title = "Let There Be Rock",
                artist_id = "AC_DC",
        },
        Album{
                id = 2,
                title = "Balls to the Wall",
                artist_id = "Accept",
        },
        Album{
                id = 3,
                title = "Restless and Wild",
                artist_id = "Accept",
        },
        Album{
                id = 5,
                title = "Big Ones",
                artist_id = "Aerosmith",
        },
]

======= query example end =======

======= execute example begin =======

[INFO ] --- [2025-03-07 21:13:16] [main.odin:93:main()] SQL: select 1

======= execute example end =======

connection closed
```
</details>

---

## Contributions

Contributions are welcome! If you find issues or have improvements, feel free to submit a pull request.

## License

This project is licensed under the MIT License.

