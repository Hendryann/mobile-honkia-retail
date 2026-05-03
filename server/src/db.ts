import mysql from 'mysql2/promise'
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
`create table if not exists auths(
	authkey char(20) invisible primary key,
	lastused date default (utc_date()),
	id char(12),

	foreign key (id) references users(id) on delete cascade on update cascade
)`,
`create event if not exists delete_old_auths
	on schedule every 1 day
	do
		delete from auths
		where lastused < date_sub(utc_date(), interval 1 day)
`
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
		[ "0", "admin", true ],
		[ "1", "user" , false ],
	]
	db.query(`insert into users(id, name, isadmin) values` + map(users), users.flat()).catch(console.error)

	if (process.env.admin_auth) db.query(`insert into auths(authkey, id) values(?, "0")`, [process.env.admin_auth]).catch(console.error)
	if (process.env.user_auth) db.query(`insert into auths(authkey, id) values(?, "1")`, [process.env.user_auth]).catch(console.error)
}

export type * from 'mysql2/promise'
export default db