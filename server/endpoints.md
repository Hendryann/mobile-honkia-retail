### GET `/userinfo`
Requires user authorization\
Return: [`User`](#user)

### GET `/login`

### GET `/register`

### GET `/items`
Gets list of items\
Return: [`Item`](#item)`[]`

### GET `/item/:id`
Gets item information\
Return: [`Item`](#item)

### GET `/item/:id/image`
Gets item image\
Return: `Blob | null`

### GET `/item/:id/purchase`
Makes a purchase, decreases stock\
Requires user authorization\
Requires JSON body, max payload 3KB\
```js
stock?: u64 = 1
```

### POST `/item/new`
Creates a new item\
Requires admin authorization\
Requires JSON body [`ItemInfo`](#iteminfo), max payload 3KB \
Return:
```js
id: string(12)
```

### PUT `/item/:id/image`
Modifies item image\
Requires admin authorization\
Acceps binary body (image), max payload 5MB

### PATCH `/item/:id`
Modifies item information\
Requires admin authorization\
Requires JSON body [`ItemInfo`](#iteminfo), max payload 3KB

### DELETE `/item/:id`
Deletes item\
Requires admin authorization

## Interfaces

### `ItemInfo`
```js
name: string(100)
type: string(25)
description: string(2000)
stock: u64
price: u64
```

### `Item`
extends `ItemInfo`
```js
id: string(12)
```

### `User`
```js
id: string(12)
name: string(100)
isadmin: 1/0
```

