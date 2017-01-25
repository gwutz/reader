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

namespace Reader {
	public class DataBase : Object {
		private Sqlite.Database db;
		private bool first_run = false;

		public DataBase () {
			// check if directory exists
			File user_app_dir = File.new_for_path (Environment.get_user_data_dir () + "/" + Environment.get_prgname ());

			try {
				user_app_dir.make_directory ();
			} catch (GLib.Error e) {
				debug(e.message);
				first_run = true;
			}
			int ec = Sqlite.Database.open (user_app_dir.get_path () + "/reader.db", out db);
			if(ec != Sqlite.OK) {
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
			string sql = "CREATE TABLE IF NOT EXISTS subscription (id INTEGER PRIMARY KEY, guid TEXT, title TEXT, description TEXt, image_url TEXT);";
			int res = this.db.prepare_v2 (sql, -1, out stmt);
			assert (res == Sqlite.OK);

			res = stmt.step ();
			if (res != Sqlite.DONE) {
				fatal ("create table", res);
			}
		}

		public Gee.List<Rss.Document> get_subscriptions () {
			Gee.List<Rss.Document> subscriptions = new Gee.ArrayList<Rss.Document>();

			// Fetch Documents from Database
			string sql = "SELECT * from subscription;";
			Sqlite.Statement stmt;
			int res = this.db.prepare_v2 (sql, -1, out stmt);
			assert (res == Sqlite.OK);

			while ( (res = stmt.step ()) == Sqlite.ROW ) {
				Rss.Document doc = new Rss.Document ();
				doc.guid = stmt.column_text (1);
				doc.title = stmt.column_text (2);
				doc.description = stmt.column_text (3);
				doc.image_url = stmt.column_text (4);
				subscriptions.add (doc);
			}

			return subscriptions;
		}

		public Rss.Document get_subscription (int64 id) {
			Rss.Document doc = new Rss.Document ();

			// Fetch Document from Database
			string sql = "SELECT * from subscription WHERE id=?;";
			Sqlite.Statement stmt;
			int res = this.db.prepare_v2 (sql, -1, out stmt);
			assert (res == Sqlite.OK);
			res = stmt.bind_int64 (1, id);
			assert (res == Sqlite.OK);

			res = stmt.step ();
			if (res != Sqlite.ROW && res != Sqlite.DONE) {
				fatal ("get_subscription with id %l failed".printf(id), res);
			}

			return doc;
		}

		/*
		 * save_subscription checks if subscription is already saved
		 * in database
		 */
		public void save_subscription (Rss.Document doc) {
			string sql = "INSERT INTO ";
		}

		/*
		 * save_item saves item to database. It checks if that item wasn't saved
		 * beforehand
		 */
		public void save_item (Rss.Document doc, Rss.Item item) {
			string sql = "INSERT INTO ...";
		}

		protected void fatal (string op, int res) {
			error ("%s: [%d] %s", op, res, this.db.errmsg ());
		}
	}
}
