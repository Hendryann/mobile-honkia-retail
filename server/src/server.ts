import express from 'express'
import http from 'http'
import jsonschema from 'jsonschema'
import jwt from 'jsonwebtoken'

export const app = express()
export const server = http.createServer(app)
const port = process.env.port ? Number(process.env.port) : 5314
server.listen(port, () => console.log('listening on', port))

export function promisifyHandler<T extends express.Handler>(fn: T): express.Handler {
	return async (req, res, next) => {
		try {
			await fn(req, res, next)
		} catch(e) {
			next(e)
		}
	}
}

export interface GetAuthRet {
	err?: string
	errcode?: number
	info?: UserInfo
}

export async function getAuth(auth?: string): Promise<GetAuthRet> {
	if (!auth)
		return { err: 'Authorization required\n', errcode: 401 }
	if (!auth.startsWith('Bearer '))
		return { err: 'Only Bearer authorization is supported\n', errcode: 400 }

	const token = auth.slice(7)
	let payload: any
	try {
		payload = jwt.verify(token, process.env.jwt_secret!)
	} catch(e) {
		return { err: 'Failed to authorize\n', errcode: 401 }
	}

	return { info: payload }
}

export const needAuth = promisifyHandler(async (req, res, next) => {
	const info = await getAuth(req.header('authorization'))
	if (info.err || !info.info) return res.status(info.errcode ?? 400).send(info.err || '').end()

	req.userinfo = info.info
	return next()
})

export const needAdmin = promisifyHandler(async (req, res, next) => {
	const info = await getAuth(req.header('authorization'))
	if (info.err || !info.info) return res.status(info.errcode ?? 400).send(info.err || '').end()
	if (!info.info.isadmin) return res.status(401).send('Not allowed\n').end()

	req.userinfo = info.info
	return next()
})

export function jsonSchemaValidate(schema: any): express.Handler {
	return (req, res, next) => {
		if (!req.body) return res.status(400).send('Needs JSON body').end()

		const r = jsonschema.validate(req.body, schema)
		if (r.valid) return next()

		res.contentType('plain')
		res.status(400)
		res.send(r.errors.map(v => v.path.join('.') + ' ' + v.message).join('\n'))
		res.end()
	}
}
