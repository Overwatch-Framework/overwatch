# ow.crypto

`ow.crypto` is a pure Lua serialization, compression, and encryption library for safely packaging data across network boundaries. It avoids ambiguous delimiters by using length-prefix encoding and a simple XOR-based encryption system.

## Features

- Serialize and deserialize Lua values: table, string, number, boolean, Entity
- Compress using run-length encoding
- Encrypt using XOR with custom or default keys
- Combine all steps into `Pack` and `Unpack` functions

---

## 🧪 Examples

### Serialize & Deserialize

```lua
local original = { name = "Riggs", level = 5, flags = {admin = true, vip = false} }
local blob = ow.crypto:Serialize(original)
local result = ow.crypto:Deserialize(blob)

PrintTable(result)
```

---

### Compress & Decompress

```lua
local compressed = ow.crypto:Compress("aaaaabbbcccccc")
local restored = ow.crypto:Decompress(compressed)
print(restored) -- Outputs: aaaaabbbcccccc
```

---

### Encrypt & Decrypt

```lua
local data = "sensitive_data"
local encrypted = ow.crypto:Encrypt(data, "MySecretKey")
local decrypted = ow.crypto:Decrypt(encrypted, "MySecretKey")

print(decrypted) -- Outputs: sensitive_data
```

---

### Full Packing and Unpacking

```lua
local payload = {
    player = "Eon",
    roles = {"developer", "admin"},
    active = true
}

local key = "SharedKey42"
local blob = ow.crypto:Pack(payload, key)

-- Transmit over network...

local decoded = ow.crypto:Unpack(blob, key)
PrintTable(decoded)
```

---

## 🔐 Default Key

If no key is provided to `Encrypt`, `Decrypt`, `Pack`, or `Unpack`, the library falls back to:
```lua
ow.crypto.DefaultKey = "ltPjQ96MXCVC8Awo"
```

---

## API

- `Serialize(data)`
- `Deserialize(blob)`
- `Compress(str)`
- `Decompress(str)`
- `Encrypt(str, key)`
- `Decrypt(str, key)`
- `Pack(data, key)`
- `Unpack(blob, key)`
