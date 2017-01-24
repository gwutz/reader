
namespace Reader {

    public class Welcome : Granite.Widgets.Welcome {
        private weak Reader.HeaderBar headerbar;

        public Welcome (Reader.HeaderBar headerbar) {
            base("No subscription", "Subscribe to a RSS Feed or import a OPML File");
            this.headerbar = headerbar;
            this.append("application-rss+xml", "Add a RSS Feed",
                        "Description");
            this.append("folder", "Import a OPML File", "Description");
            this.valign = Gtk.Align.FILL;
            this.halign = Gtk.Align.FILL;
            this.vexpand = true;
            
            this.activated.connect ((i) => {
                if (i == 0) {
                    headerbar.add_pop.popup ();
                }
            });
        }
    }
}
