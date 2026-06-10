import { hashPassword } from '../auth'
import db from '../db'
import * as server from '../server'
import express from 'express'
import jwt from 'jsonwebtoken'
import { OAuth2Client } from 'google-auth-library'
const googleClient = new OAuth2Client()

server.app.get('/userinfo',
	server.needAuth,
	(req, res) => {
		res.json(req.userinfo).end()
	}
)

server.app.post('/login',
	express.json({ limit: '3kb', type: () => true }),
	server.jsonSchemaValidate(await import('../schema/login.json')),
	server.promisifyHandler(async (req, res) => {
		const [[user]] = await db.execute('select name, isadmin from users where name = ? and password = ?', [req.body.username, hashPassword(req.body.username, req.body.password)]) as any
		if (!user) return res.status(401).end()

		const token = jwt.sign(user, process.env.jwt_secret!)
		res.json({ token }).end()
	})
)

server.app.post('/register',
	express.json({ limit: '3kb', type: () => true }),
	server.jsonSchemaValidate(await import('../schema/login.json')),
	server.promisifyHandler(async (req, res) => {
		const [[exists]] = await db.execute('select name from users where name = ?', [req.body.username]) as any
		if (exists) return res.status(400).send('User already exist').end()

		await db.execute('insert into users(name, password) values(?, ?)', [req.body.username, hashPassword(req.body.username, req.body.password)])

		const token = jwt.sign({ name: req.body.username, isadmin: false }, process.env.jwt_secret!)
		res.json({ token }).end()
	})
)

server.app.post('/google-login',
    express.json({ limit: '3kb', type: () => true }),
    server.promisifyHandler(async (req, res) => {
        const ticket = await googleClient.verifyIdToken({
            idToken: req.body.idToken,
            audience: process.env.GOOGLE_WEB_CLIENT_ID
        })
        const payload = ticket.getPayload()
        if (!payload?.email) return res.status(401).end()

        const [[exists]] = await db.execute('select name, isadmin from users where name = ?', [payload.email]) as any
        if (!exists) {
            await db.execute('insert into users(name, password) values(?, null)', [payload.email])
        }

        const user = exists ?? { name: payload.email, isadmin: false }
        const token = jwt.sign(user, process.env.jwt_secret!)
        res.json({ token }).end()
    })
)
