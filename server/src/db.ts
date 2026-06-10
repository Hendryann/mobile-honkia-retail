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
  created_at timestamp default current_timestamp,

	constraint image check (length(image) <= 5242880)
)`,
`create table if not exists users(
	name varchar(100) primary key,
	isadmin boolean default false,
	password binary(32) invisible
)`,

].map(q => db.query(q)))

if (dev) {
	function map(arr: any[][]) {
		return arr.map(v => '(' + v.map(v => '?').join(',') + ')').join(',')
	}

	const items = [
		[ "0", "Light Telescope", "tool", "A type of telescope to observe close-up of distance space objects (like planets) by visible light", 100, 100 ],
		[ "1", "Radio Telescope", "tool", "A type of telescope to detect radio signals from outer space", 100, 100 ],
		[ "2", "Otherworldly Crystal", "material", "A mysterious material from the outer galaxy. ", 1, 1000000 ],
		[ "4", "Lifeform Analyzer", "tool", "A tool to detect life outside within a planet" , 20 , 2000  ],
		[ "5", "Planet Analyzer", "tool", "A tool to analyze a planet's atmosphere & surface compositions", 10, 9],
		[ "6", "Neutronium", "material", "Don't worry about it" , 1, 5000000],
	]
	db.query(`insert into items(id, name, type, description, stock, price) values ` + map(items), items.flat()).catch(console.error)

	const users = [
		[ "admin", true, process.env.admin_password ? hashPassword('admin', process.env.admin_password) : null ],
		[ "user" , false, hashPassword('user', 'user') ],
	]
	db.query(`insert into users(name, isadmin, password) values` + map(users), users.flat()).catch(console.error)
}

export type * from 'mysql2/promise'
export default db
