import 'dotenv/config'
import db from './db'
import {server, app} from './server'
import './routes/item'
import './routes/user'
import type express from 'express'

app.use((err: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
	console.error(`${req.method} ${req.originalUrl}:`)
	console.error(err)

	if (!res.closed) {
		if (res.headersSent) {
			res.destroy()
		} else {
			res.status(500).end()
		}
	}
})


process.once('SIGINT', () => {
	console.log('Closing')
	db.end()
	server.emit('beforeclose')
	server.close()
})

