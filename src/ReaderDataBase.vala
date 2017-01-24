
namespace Reader {
	public class DataBase : Object {
		private Sqlite.Database db;

		public DataBase () {
			// check if directory exists
			File user_app_dir = File.new_for_path (Environment.get_user_data_dir () + "/" + Environment.get_prgname ());
			user_app_dir.make_directory ();
			int ec = Sqlite.Database.open (user_app_dir.get_path () + "/reader.db", out db);
			if(ec != Sqlite.OK) {
				error (db.errmsg ());
			}
		}
	}
}
