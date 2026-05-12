import crypto from 'crypto'

export function hashPassword(username: string, password: string) {
	return crypto.createHmac('sha256', process.env.password_secret!).update(password + username).digest()
}