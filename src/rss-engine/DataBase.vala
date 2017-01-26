/* ReaderDataBase.vala
 *
 * Copyright (C) 2017 Guenther Wutz <info@gunibert.de>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

namespace Reader.Engine {
	public class DataBase : Object {
		private Sqlite.Database db;
		private bool first_run = false;

		public DataBase () {
			// check if directory exists
			File user_app_dir = File.new_for_path (Environment.get_user_data_dir () + "/" + Environment.get_prgname ());

			try {
				user_app_dir.make_directory ();
			} catch (GLib.Error e) {
				debug (e.message);
				first_run = true;
			}
			int ec = Sqlite.Database.open (user_app_dir.get_path () + "/reader.db", out db);
			if (ec != Sqlite.OK) {
				error (db.errmsg ());
			}

			if (first_run) {
				create_schema ();
			}
		}

		/*
		 * creates schema table if this is the first run
		 * TODO: add a possibility to version the database
		 */
		private void create_schema () {
			Sqlite.Statement stmt;
			string sql = "CREATE TABLE IF NOT EXISTS subscription (link TEXT PRIMARY KEY NOT NULL, title TEXT, description TEXT, image_url TEXT);";
			int res = this.db.prepare_v2 (sql, -1, out stmt);
			assert (res == Sqlite.OK);

			res = stmt.step ();
			if (res != Sqlite.DONE) {
				fatal ("create table", res);
			}

			sql = "CREATE TABLE IF NOT EXISTS items (guid TEXT PRIMARY KEY NOT NULL, title TEXT, content TEXT, pub_date TEXT, sub_id TEXT NOT NULL, FOREIGN KEY(sub_id) REFERENCES subscription(link));";
			res = this.db.prepare_v2 (sql, -1, out stmt);
			assert (res == Sqlite.OK);

			res = stmt.step ();
			if (res != Sqlite.DONE) {
				fatal ("create table", res);
			}
		}

		public List<Subscription> get_subscriptions () {
			List<Subscription> subscriptions = new List<Subscription>();

			// Fetch Documents from Database
			string sql = "SELECT link, title, description, image_url from subscription;";
			Sqlite.Statement stmt;
			int res = this.db.prepare_v2 (sql, -1, out stmt);
			assert (res == Sqlite.OK);

			while ( (res = stmt.step ()) == Sqlite.ROW ) {
				var sub = new Subscription ();
				sub.link = stmt.column_text (0);
				sub.title = stmt.column_text (1);
				sub.description = stmt.column_text (2);
				sub.image_url = stmt.column_text (3);

				get_items (sub);
				subscriptions.append (sub);
			}

			return subscriptions;
		}

		public Subscription get_subscription (string id) {
			string sql = "SELECT link, title, description, image_url from subscription WHERE link='%s';".printf(id);
			Sqlite.Statement stmt;
			int res = this.db.prepare_v2 (sql, -1, out stmt);
			assert (res == Sqlite.OK);
			res = stmt.step ();
			assert (res == Sqlite.ROW);
			var sub = new Subscription ();
			sub.link = stmt.column_text (0);
			sub.title = stmt.column_text (1);
			sub.description = stmt.column_text (2);
			sub.image_url = stmt.column_text (3);

			get_items (sub);
			return sub;
		}

		public void get_items (Subscription sub) {
		    string sql = "SELECT guid, title, content, pub_date, sub_id FROM items WHERE sub_id = '%s';".printf(sub.link);
		    Sqlite.Statement stmt;
		    int res = this.db.prepare_v2 (sql, -1, out stmt);
		    assert (res == Sqlite.OK);

			while ( (res = stmt.step ()) == Sqlite.ROW ) {
			    var item = new Item ();
			    item.id = stmt.column_text (0);
			    item.title = stmt.column_text (1);
			    item.content = stmt.column_text (2);
			    item.pub_date = stmt.column_text (3);
			    sub.add_item (item);
			}
		}

		public Item get_item (string id) {
		    string sql = "SELECT guid, title, content, pub_date FROM items WHERE guid = '%s';".printf(id);
		    Sqlite.Statement stmt;
		    int res = this.db.prepare_v2 (sql, -1, out stmt);
		    assert (res == Sqlite.OK);

		    res = stmt.step ();
		    if (res != Sqlite.ROW) {
		        fatal ("Can't fetch Item", res);
		    }
		    var item = new Item ();
		    item.id = stmt.column_text (0);
		    item.title = stmt.column_text (1);
		    item.content = stmt.column_text (2);
		    item.pub_date = stmt.column_text (3);

		    return item;
		}

		/*
		 * save_subscription checks if subscription is already saved
		 * in database
		 */
		public bool save_subscription (Subscription sub) {
			string sql = "INSERT INTO subscription (link, title, description, image_url) VALUES (?, ?, ?, ?)";

			Sqlite.Statement stmt;
			int res = this.db.prepare_v2 (sql, -1, out stmt);
			assert (res == Sqlite.OK);
			res = stmt.bind_text (1, sub.link);
			assert (res == Sqlite.OK);
			res = stmt.bind_text (2, sub.title);
			assert (res == Sqlite.OK);
			res = stmt.bind_text (3, sub.description);
			assert (res == Sqlite.OK);
			res = stmt.bind_text (4, sub.image_url);
			assert (res == Sqlite.OK);

			res = stmt.step ();
			if (res != Sqlite.DONE) {
			    if (res != Sqlite.CONSTRAINT) {
			        fatal ("Database error", res);
			    }
			}

			if (res == Sqlite.CONSTRAINT) return false;

			foreach (Item item in sub.items) {
			    save_item (sub, item);
			}

			return true;
		}

		/*
		 * save_item saves item to database. It checks if that item wasn't saved
		 * beforehand
		 */
		public void save_item (Subscription sub, Item item) {
			string sql = "INSERT INTO items (guid, title, content, pub_date, sub_id) VALUES (?, ?, ?, ?, ?);";

		    Sqlite.Statement stmt;
		    int res = this.db.prepare_v2 (sql, -1, out stmt);
			assert (res == Sqlite.OK);
			res = stmt.bind_text (1, item.id);
			assert (res == Sqlite.OK);
			res = stmt.bind_text (2, item.title);
			assert (res == Sqlite.OK);
			res = stmt.bind_text (3, item.content);
			assert (res == Sqlite.OK);
			res = stmt.bind_text (4, item.pub_date);
			assert (res == Sqlite.OK);
			res = stmt.bind_text (5, sub.link);
			assert (res == Sqlite.OK);

			res = stmt.step ();
			if (res != Sqlite.DONE) {
			    if (res != Sqlite.CONSTRAINT) {
			        fatal ("Database error", res);
			    }
			}
		}

		protected void fatal (string op, int res) {
			error ("%s: [%d] %s", op, res, this.db.errmsg ());
		}
	}
}
