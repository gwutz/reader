
namespace Reader {
    public class DataManager : Object {

        private Rss.Parser parser {get; private set; default = new Rss.Parser(); }
        private Reader.DataBase db {get; private set; default = new Reader.DataBase(); }

        public DataManager() {
        }

        public Gee.List<Rss.Document> documents {
            get;
            set;
            default = new Gee.ArrayList<Rss.Document>();
        }

        public BackgroundJob add_url (string url) {
            Reader.Application.instance.controller.added_feed.connect((doc) => {
                print("added document\n");
                documents.add(doc);
            });
            return new FetchRss(url, parser);
        }

        class FetchRss : BackgroundJob {
            private string url;
            private Rss.Parser parser;
            private Rss.Document doc;

            public FetchRss(string url, Rss.Parser parser) {
                this.url = url;
                this.parser = parser;
            }

            public override void execute_in_background() {
                Soup.Session session = new Soup.Session();
                Soup.Message msg = new Soup.Message ("GET", url);
                session.send_message(msg);

                try {
                    parser.load_from_data ((string) msg.response_body.data,
                    (ulong)  msg.response_body.length);
                    doc = parser.get_document ();
                    //documents.add(doc);
                    if(doc.image_url == null || doc.image_url.length == 0) {
                        var link = doc.link;
                        var file = File.new_for_uri(link);
                        if(file.has_parent(null)) {
                            link = file.get_parent ().get_uri ();
                        }
                        Soup.Message iconmsg = new Soup.Message ("GET", link +
                                                                 "favicon.ico");
                        session.send_message (iconmsg);
                        if(iconmsg.status_code == 200) {
                            doc.image_url = link + "favicon.ico";
                        }
                    }
                } catch (Error e) {
                    error(e.message);
                }
            }

            public override void execute_in_main() {
                Reader.Application.instance.controller.added_feed(doc);
            }
        }
    }
}
