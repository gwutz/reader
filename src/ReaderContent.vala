/* ReaderContent.vala
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

    public class Content : Gtk.Box {

        public Gtk.InfoBar info_bar;
        public WebKit.WebView   webview;

        private Gtk.TreeStore   sidebar;
        private Gtk.ListStore   items;
        
        private bool first_sidebar_item = true;

        public Content () {
            Object(orientation: Gtk.Orientation.VERTICAL, spacing: 0);
            
            // Infobar
            this.info_bar = new Gtk.InfoBar ();
            this.info_bar.set_message_type (Gtk.MessageType.WARNING);
            this.info_bar.set_show_close_button (true);
            this.info_bar.response.connect (() => {
                this.info_bar.hide();
                this.remove (this.info_bar);
            });
            
            Gtk.Paned pane = new Gtk.Paned (Gtk.Orientation.HORIZONTAL);
            this.pack_end (pane);
            
            var tree = new Gtk.TreeView ();
            tree.get_style_context ().add_class ("sidebar");

            sidebar = new Gtk.TreeStore(3, typeof(string), typeof(Gdk.Pixbuf), typeof(string));
            tree.set_model(sidebar);
            tree.set_headers_visible(false);
            tree.activate_on_single_click = true;
            tree.row_activated.connect ((path, column) => {
                Gtk.TreeIter iter_sub;
                sidebar.get_iter(out iter_sub, path);
                string id;
                sidebar.get(iter_sub, 2, out id, -1);
                var sub = Reader.Application.instance.controller.get_subscription (id);
                populate_items (sub);
            });
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
            items = new Gtk.ListStore(3, typeof(string), typeof(string), typeof(string));
            list.set_model(items);
            list.set_headers_visible(false);
            list.activate_on_single_click = true;
            list.row_activated.connect((path, column) => {
                Gtk.TreeIter iter_item;
                items.get_iter(out iter_item, path);
                string id;
                items.get(iter_item, 2, out id, -1);
                var item = Reader.Application.instance.controller.get_item(id);
                populate_web_view(item);
            });
            list.insert_column_with_attributes (-1, "Date", cellrenderer,
                                                "text", 0, null);
            list.insert_column_with_attributes (-1, "Title", cellrenderer,
                                                "text", 1, null);
            items.set_sort_column_id (0, Gtk.SortType.DESCENDING);
            scrolllist.add(list);
            pane2.add1(scrolllist);

            webview = new WebKit.WebView ();
            var settings = webview.get_settings();
            Pango.FontDescription font =
                Pango.FontDescription.from_string("Open Sans 13");
            settings.set_default_font_family(font.get_family());
            settings.set_default_font_size(font.get_size() / Pango.SCALE);
            webview.settings = settings;
            webview.decide_policy.connect ((decision, type) => {
                if (type == WebKit.PolicyDecisionType.NAVIGATION_ACTION) {
                    WebKit.NavigationPolicyDecision nav = decision as WebKit.NavigationPolicyDecision;
                    if (nav.get_navigation_action().get_navigation_type() == WebKit.NavigationType.LINK_CLICKED) {
                        nav.ignore();
                        string dest = nav.get_navigation_action ().get_request ().get_uri();
                        List<string> uris = new List<string>();
                        uris.append(dest);
                        AppInfo app = AppInfo.get_default_for_uri_scheme("http");
                        app.launch_uris(uris, null);
                        return true;
                    }
                }
                return false;
            });
            pane2.add2(webview);

            // add signals
            Reader.Engine.Fetcher.instance.new_subscription.connect (add_subscription);

            var subscriptions = Reader.Engine.Fetcher.instance.get_subscriptions ();
            foreach (Reader.Engine.Subscription sub in subscriptions) {
                add_subscription (sub);
            }
            if (subscriptions.first () != null)
                populate_items (subscriptions.first ().data);
        }

        public void add_subscription (Reader.Engine.Subscription sub) {
            Gtk.TreeIter root;
            sidebar.append(out root, null);
            File icon = File.new_for_uri(sub.image_url);
            var stream = icon.read();
            var pixbuf = new Gdk.Pixbuf.from_stream(stream);
            if(pixbuf.width > 16) {
                pixbuf = pixbuf.scale_simple(16, 16, Gdk.InterpType.BILINEAR);
            }
            sidebar.set(root, 0, sub.title, 1, pixbuf, 2, sub.link);
            if (first_sidebar_item) {
                first_sidebar_item = false;
                populate_items (sub);
            }
        }

        public void populate_items (Reader.Engine.Subscription sub) {
            items.clear ();
            Gtk.TreeIter root;
            foreach(Reader.Engine.Item item in sub.items) {
                items.append(out root);
                string date = item.date.format ("%d.%m %H:%M");
                items.set(root, 0, date, 1, item.title, 2, item.id);
            }
            populate_web_view(sub.items.first().data);
        }

        public void populate_web_view (Reader.Engine.Item item) {
            webview.load_html(@"<html><head><style>h1 {font-size: 32px;font-weight: 300;text-align: center;}</style></head><body><h1>%s</h1>%s</body></html>".printf(item.title, item.content), null);
        }
    }
}
