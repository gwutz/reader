
namespace Reader {
    public const string READER_ERROR = "ReaderShowError";
    public const string READER_ADD_URL = "ReaderAddUrl";

    public class Controller : Object {
        private Reader.DataManager manager {get; set;}
        private Reader.Workerpool pool {get; set; default = new Reader.Workerpool();}

        public Controller () {
            this.manager = new Reader.DataManager();
        }

        public signal void added_feed(Rss.Document doc);

        public void add_actions () {
            var show_error = new SimpleAction(READER_ERROR,
                                              VariantType.STRING);
            show_error.activate.connect ((val) => {
                this.show_error(val.get_string());
            });

            var add_url = new SimpleAction(READER_ADD_URL, VariantType.STRING);
            add_url.activate.connect ((val) => {
                var job = manager.add_url(val.get_string());
                pool.enqueue(job);
            });

            Reader.Application.instance.add_action(show_error);
            Reader.Application.instance.add_action(add_url);
        }

        public void show_error (string message) {
            var window = Reader.Application.instance.get_main_window ();
            Gtk.InfoBar info_bar = window.info_bar;
            // normally a show is enough but there is a really nasty bug 
            // and the only workaround at the moment is detach/attach 
            // together with hide/show
            var content = window.content;
            content.pack_start (info_bar, false, false, 0);
            info_bar.get_content_area().get_children().foreach((child) => {
                var content_area = info_bar.get_content_area();
                content_area.remove(child);
            });
            info_bar.get_content_area ().add(new Gtk.Label(message));
            info_bar.show_all();
        }

        public Rss.Item get_rss_item(int nr) {
            print("items %d\n", manager.documents.size);
            var doc = manager.documents.get(0);
            return doc.get_items().nth_data(nr);
        }
    }

}
