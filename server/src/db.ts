import mysql from 'mysql2/promise'
import { hashPassword } from './auth'
const { db_host, db_port, db_user, db_password, db_database, dev } = process.env

const db = await mysql.createConnection({
	host: db_host,
	port: db_port ? Number(db_port) : undefined,
	user: db_user,
	password: db_password,
})

if (dev) await db.query(`drop database if exists ${db_database}`)

await db.query(`create database if not exists ${db_database}`)
await db.query(`use ${db_database}`);

await Promise.all([
`create table if not exists items(
	id char(12) primary key,
	name varchar(100) not null,
	type varchar(25) not null,
	description varchar(2000) not null,
	stock int unsigned not null,
	price int unsigned not null,
	image mediumblob invisible,

	constraint image check (length(image) <= 5242880)
)`,
`create table if not exists users(
	id char(12) primary key,
	name varchar(100) not null,
	isadmin boolean default false,
	password binary(50) invisible
)`,

].map(q => db.query(q)))

if (dev) {
	function map(arr: any[][]) {
		return arr.map(v => '(' + v.map(v => '?').join(',') + ')').join(',')
	}

	const items = [
		[ "0", "telescope"     , "tool"     , "see stars", 100, 100000, "abc" ],
		[ "1", "space bracelet", "equipment", "its cool" , 20 , 10000 , null ],
	]
	db.query(`insert into items(id, name, type, description, stock, price, image) values ` + map(items), items.flat()).catch(console.error)

	const users = [
		[ "0", "admin", true, process.env.admin_password ? hashPassword('admin', process.env.admin_password) : null ],
		[ "1", "user" , false, 'user' ],
	]
	db.query(`insert into users(id, name, isadmin, password) values` + map(users), users.flat()).catch(console.error)
}

export type * from 'mysql2/promise'
export default db