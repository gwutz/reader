
namespace Reader {

    public class ReaderWindow : Gtk.ApplicationWindow {

        public Gtk.InfoBar    info_bar;
        public Gtk.Box        content;
        public WebKit.WebView webview;

        private Gtk.TreeStore sidebar;
        private Gtk.ListStore items;

        public ReaderWindow(Gtk.Application app) {
            Object (application: app);
            build_ui ();

            Reader.Application.instance.controller.added_feed.connect(add_rss_document);
        }

        private void build_ui () {
            Reader.HeaderBar headerbar = new Reader.HeaderBar ();
            this.set_titlebar (headerbar);

            this.content = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
            this.add (content);

            this.info_bar = new Gtk.InfoBar ();
            this.info_bar.set_message_type (Gtk.MessageType.WARNING);
            this.info_bar.set_show_close_button (true);
            this.info_bar.response.connect (() => {
                this.info_bar.hide();
                content.remove (this.info_bar);
            });

            Gtk.Paned pane = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
            this.content.pack_end (pane);

            var tree = new Gtk.TreeView ();
            tree.get_style_context ().add_class ("sidebar");

            sidebar = new Gtk.TreeStore(2, typeof(string), typeof(Gdk.Pixbuf));
            tree.set_model(sidebar);
            tree.set_headers_visible(false);
            var pixbufrenderer = new Gtk.CellRendererPixbuf ();
            tree.insert_column_with_attributes(-1, "Icon",
                                               pixbufrenderer,
                                               "pixbuf", 1, null);
            var cellrenderer = new Gtk.CellRendererText ();
            tree.insert_column_with_attributes(-1, "Abonnement",
                                               cellrenderer,
                                               "text", 0, null);

            Gtk.TreeIter root;
            pane.add1(tree);
            tree.width_request = 200;

            Gtk.Paned pane2 = new Gtk.Paned (Gtk.Orientation.VERTICAL);
            pane2.set_position(150);
            pane.add2 (pane2);
            
            var scrolllist = new Gtk.ScrolledWindow(null, null);
            var list = new Gtk.TreeView ();
            items = new Gtk.ListStore(1, typeof(string));
            list.set_model(items);
            list.set_headers_visible(false);
            list.activate_on_single_click = true;
            list.row_activated.connect((path, column) => {
                var item = Reader.Application.instance.controller.get_rss_item(path.get_indices()[0]);
                populate_web_view(item);
            });
            list.insert_column_with_attributes (-1, "Title", cellrenderer,
                                                "text", 0, null);
            scrolllist.add(list);
            pane2.add1(scrolllist);

            webview = new WebKit.WebView ();
            var settings = webview.get_settings();
            Pango.FontDescription font =
                Pango.FontDescription.from_string("Open Sans 13");
            settings.set_default_font_family(font.get_family());
            settings.set_default_font_size(font.get_size() / Pango.SCALE);
            webview.settings = settings;
            pane2.add2(webview);
        }

        public void add_rss_document (Rss.Document doc) {
            Gtk.TreeIter root;
            sidebar.append(out root, null);
            File icon = File.new_for_uri(doc.image_url);
            var stream = icon.read();
            var pixbuf = new Gdk.Pixbuf.from_stream(stream);
            if(pixbuf.width > 16) {
                pixbuf = pixbuf.scale_simple(16, 16, Gdk.InterpType.BILINEAR);
            }
            sidebar.set(root, 0, doc.title, 1, pixbuf);
            populate_rss_items(doc);
        }

        public void populate_rss_items (Rss.Document doc) {
            Gtk.TreeIter root;
            foreach(Rss.Item item in doc.get_items()) {
                items.append(out root);
                items.set(root, 0, item.title);
            }
            populate_web_view(doc.get_items().first().data);
        }

        public void populate_web_view (Rss.Item item) {
            webview.load_html(@"<html><head><style>h1 {font-size: 32px;font-weight: 300;text-align: center;}</style></head><body><h1>%s</h1>%s</body></html>".printf(item.title, item.description), null);

        }

    }

}
