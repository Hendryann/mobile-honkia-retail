### POST `/login`
Requires JSON body, max payload 3KB
```js
username: string
password: string
```
Return: `{ token: string }`

### POST `/register`
Requires JSON body, max payload 3KB
```js
username: string
password: string
```
Return: `{ token: string }`

### POST `/google-login`
Requires JSON body, max payload 3KB
```js
idToken: string
```
Return: `{ token: string }`

### GET `/userinfo`
Requires user authorization\
Return: [`User`](#user)

### GET `/items`
Gets list of items\
Supports query params: `?limit=number`, `?category=string`\
Return: [`Item`](#item)`[]`

### GET `/item/types`
Gets list of distinct item types\
Return: `string[]`

### GET `/item/:id`
Gets item information\
Return: [`Item`](#item)

### GET `/item/:id/image`
Gets item image\
Return: `Blob | null`

### POST `/item/:id/purchase`
Makes a purchase, decreases stock\
Requires user authorization\
Requires JSON body, max payload 3KB\
```js
amount?: u64 = 1
```

### POST `/item/new`
Creates a new item\
Requires admin authorization\
Requires JSON body [`ItemInfo`](#iteminfo), max payload 3KB\
Return:
```js
id: string(12)
```

### PUT `/item/:id/image`
Modifies item image\
Requires admin authorization\
Accepts binary body (image), max payload 5MB

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
name: string(100)
isadmin: 1/0
```
