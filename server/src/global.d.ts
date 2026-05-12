interface UserInfo {
	name: string
	isadmin: boolean
}

declare namespace Express {
	interface Request {
		userinfo?: UserInfo
	}
}