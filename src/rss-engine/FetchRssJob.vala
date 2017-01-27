/* FetchRssJob.vala
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

    public class FetchRssJob : BackgroundJob {
        private string url;
        private Rss.Parser parser;
        private Subscription subscription;
        private bool refresh;

        public FetchRssJob (string url, Rss.Parser parser, bool refresh = false) {
            this.url = url;
            this.parser = parser;
            this.refresh = refresh;
        }

        public override void execute_in_background () {
            Soup.Session session = new Soup.Session ();
            Soup.Message msg = new Soup.Message ("GET", url);
            session.send_message (msg);

            try {
                parser.load_from_data ((string) msg.response_body.data,
                					   (ulong)  msg.response_body.length);
                Rss.Document doc = parser.get_document ();
                if (doc.image_url == null || doc.image_url.length == 0) {
                    var link = doc.link;
                    var file = File.new_for_uri (link);
                    if (file.has_parent (null)) {
                        link = file.get_parent ().get_uri ();
                    }
                    Soup.Message iconmsg = new Soup.Message ("GET", link +
                                                             "favicon.ico");
                    session.send_message (iconmsg);
                    if (iconmsg.status_code == 200) {
                        doc.image_url = link + "favicon.ico";
                    }
                }
                subscription = convertDocument (doc);
                subscription.feed_url = url;
            } catch (Error e) {
                error (e.message);
            }
        }

        private Subscription convertDocument(Rss.Document doc) {
            var sub = new Subscription ();
            sub.link = doc.link;
            sub.title = doc.title;
            sub.description = doc.description;
            sub.image_url = doc.image_url;

            foreach (Rss.Item item in doc.get_items ()) {
                var i = new Item ();
                i.id = item.guid;
                i.title = item.title;
                if (item.content != null) {
                    i.content = item.content;
                } else {
                    i.content = item.description;
                }
                if (item.pub_date == null) {
                    //Sun, 07 Jan 2017 18:48:00 +0000
                    var locale = Intl.setlocale ();
                    Intl.setlocale (LocaleCategory.TIME, "C");
                    i.pub_date = new DateTime.now_local ().format ("%a, %d %b %Y %H:%M:%S +0000");
                    Intl.setlocale (LocaleCategory.TIME, locale);
                } else {
                    i.pub_date = item.pub_date;
                }
                sub.add_item (i);
            }

            return sub;
        }

        public override void execute_in_main () {
            if (!refresh) {
                Reader.Engine.Fetcher.instance.save_new_subscription (subscription);
            } else {
                Reader.Engine.Fetcher.instance.update_subscription (subscription);
            }
        }
	}
}
