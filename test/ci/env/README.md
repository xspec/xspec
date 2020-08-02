### `*.env`

- `global.env` is read first.
- `name=value`
- `name=` to unset
- No quotation even if `value` contains a space.
- Blank lines are skipped.
- Lines starting with `#` are skipped. `#` cannot be used in other places.

### Note

- XML Calabash will use Saxon jar in its own `lib` directory.
  - You need to delete `lib/Saxon-*.jar` and add our Saxon jar to classpath.
- BaseX test requires XML Calabash.
