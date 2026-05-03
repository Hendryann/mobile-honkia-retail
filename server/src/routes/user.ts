import * as server from '../server'

server.app.get('/userinfo',
	server.needAuth,
	(req, res) => {
		res.json(req.userinfo).end()
	}
)

server.app.post('/login',
	(req, res) => {
		console.warn('unimplemented POST /login')
		res.end()
	}
)

server.app.post('/register',
	(req, res) => {
		console.warn('unimplemented POST /register')
		res.end()
	}
)
