/* Fetcher.vala
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

/*
 * Fetcher is the main entry point for our Engine. This is a self-contained blob
 * on classes and functionality to Fetch RSS Feeds from the web, parse them to
 * model objects and save them in our database
 */
namespace Reader.Engine {
	public class Fetcher : Object {

		/*
		 * Singleton
		 */
        private static Fetcher _instance = null;
        public static Fetcher instance {
            get { return _instance; }
            private set {
                assert (_instance == null);
                _instance = value;
            }
        }

		/*
		 * Public signals
		 */
		public signal void new_subscription (Subscription subscription);
		public signal void engine_error (string message);

		Workerpool pool { private get; private set; default = new Workerpool (); }
		Rss.Parser parser { private get; private set; default = new Rss.Parser (); }
		DataBase db { private get; private set; default = new DataBase (); }

		public Fetcher () {
			_instance = this;
		}

		/*
		 * adds a subscription to the engine machinery. This gets encapsulated
		 * in a job for our Workerpool. After fetching and parsing this new source
		 * we save it to our database. Fires new_subscription signal after success
		 */
		public void add_subscription (string url) {
		    debug ("Fetching subscription [url=%s]", url);
			FetchRssJob job = new FetchRssJob (url, parser);
			pool.enqueue (job);
		}

		public List<Subscription> get_subscriptions () {
            return this.db.get_subscriptions ();
		}

		public Subscription get_subscription (string id) {
		    return this.db.get_subscription (id);
		}

		public Item get_item (string id) {
		    return this.db.get_item (id);
		}

		/*
		 * saves a new subscription into the database. This gets only
		 * invoked if there is a brand new subscription
		 */
		public void save_new_subscription (Subscription subscription) {
			debug ("Save new subscription [title=%s] in database", subscription.title);
			if (this.db.save_subscription (subscription)) {
			    new_subscription (subscription);
			} else {
			    engine_error ("Can't save subscription - missing guid?");
			}
		}


	}
}
