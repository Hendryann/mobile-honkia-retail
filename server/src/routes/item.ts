import db, { ResultSetHeader } from '../db'
import * as server from '../server'
import express from 'express'
import crypto from 'crypto'

server.app.get('/items',
	server.promisifyHandler(async (req, res) => {
		const [items] = await db.execute('select * from items where') as any
		res.json(items).end()
	})
)

server.app.get('/item/:id',
	server.promisifyHandler(async (req, res) => {
		const [[item]] = await db.execute('select * from items where id = ?', [req.params.id]) as any
		if (!item) return res.status(404).end()
		res.json(item).end()
	})
)

server.app.get('/item/:id/image',
	server.promisifyHandler(async (req, res) => {
	const [[imagedata]] = await db.execute('select image from items where id = ?', [req.params.id]) as any
	res.send(imagedata.image).end()
}))

server.app.post('/item/:id/purchase',
	server.needAuth,
	express.json({ limit: '3kb', type: () => true }),
	server.jsonSchemaValidate(await import('../schema/purchase.json')),
	server.promisifyHandler(async (req, res) => {
		const {amount = 1} = req.body

		const [[info]] = await db.execute('select stock from items where id = ?', [req.params.id]) as any
		if (!info) return res.status(404).end()
		if (amount && info.stock < amount) return res.status(400).send('amount too much\n').end()

		await db.execute('update items set stock = stock - ? where id = ?', [amount ?? 1, req.params.id])
		res.end()
	})
)

server.app.post('/item/new',
	server.needAdmin,
	express.json({ limit: '3kb', type: () => true }),
	server.jsonSchemaValidate(await import('../schema/item.json')),
	server.promisifyHandler(async (req, res) => {
		const b = req.body
		const id = crypto.randomBytes(9).toString('base64url').slice(0, 12)
		await db.execute(
			'insert into items(id, name, type, description, stock, price) values(?, ?, ?, ?, ?, ?)',
			[ id, b.name, b.type, b.description, b.stock, b.price ]
		)
		res.json({
			id: id
		})
		res.end()
	})
)

server.app.put('/item/:id/image',
	server.needAdmin,
	express.raw({ limit: '5mb', type: () => true }),
	server.promisifyHandler(async (req, res) => {
		const [qres] = await db.execute('update items set image = ? where id = ?', [req.body || null, req.params.id]) as [ResultSetHeader, any[]]
		if (qres.affectedRows == 0) return res.status(404).end()
		res.end()
	})
)

server.app.patch('/item/:id',
	server.needAdmin,
	express.json({ limit: '3kb', type: () => true }),
	server.jsonSchemaValidate(await import('../schema/item.json')),
	server.promisifyHandler(async (req, res) => {
		const b = req.body
		const [qres] = await db.execute(
			'update items set name=?, type=?, description=?, stock=?, price=? where id=?',
			[ b.name, b.type, b.description, b.stock, b.price, req.params.id ]
		) as [ResultSetHeader, any[]]
		if (qres.affectedRows == 0) res.status(404).end()
		res.end()
	})
)

server.app.delete('/item/:id',
	server.needAdmin,
	server.promisifyHandler(async (req, res) => {
		await db.execute('delete from items where id = ?', req.params.id)
		res.end()
	})
)