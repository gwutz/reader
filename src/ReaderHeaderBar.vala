
namespace Reader {
    
    public class HeaderBar : Gtk.HeaderBar {
        private Gtk.Entry url_entry;
        private Gtk.Button url_entry_enter;
        public  Gtk.Popover add_pop;

        public HeaderBar () {
            this.get_style_context ().add_class ("primary-toolbar");
            this.set_show_close_button (true);

            Gtk.Image add_img = new Gtk.Image.from_icon_name ("list-add",
                                                Gtk.IconSize.LARGE_TOOLBAR);
            Gtk.ToolButton add = new Gtk.ToolButton (add_img, 
                                                "Neues Abonnement...");
            this.pack_start (add);
            add_pop = new Gtk.Popover (add);
            add_pop.set_position (Gtk.PositionType.BOTTOM);

            Gtk.Box popbox = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 10);
            popbox.margin = 10;
            add_pop.add(popbox);

            url_entry = new Gtk.Entry ();
            url_entry.width_request = 250;
            url_entry.get_buffer().inserted_text.connect((pos, str, len) => {
                if(url_entry.get_text_length() > 0) {
                    url_entry_enter.set_action_target_value(
                        new Variant.string(url_entry.get_text()));
                }
            });
            popbox.pack_start(url_entry);

            url_entry_enter = new Gtk.Button.with_label ("Add Feed...");
            url_entry_enter.set_action_name("app." + Reader.READER_ADD_URL);
            url_entry_enter.clicked.connect(() => {
                url_entry_enter.set_action_target_value(
                    new Variant.string(url_entry.get_text()));
                add_pop.popdown();
            });
            url_entry.activate.connect(() => {
                url_entry_enter.activate();
            });
            popbox.pack_start(url_entry_enter);
            popbox.show_all();

            add.clicked.connect (() => {
                add_pop.popup ();
            });

            Gtk.Image refresh_img = new Gtk.Image.from_icon_name ("view-refresh",
                                                Gtk.IconSize.LARGE_TOOLBAR);
            Gtk.ToolButton refresh = new Gtk.ToolButton (refresh_img, null);
            this.pack_start (refresh);
            refresh.set_action_name("app." + Reader.READER_ERROR);
            refresh.set_action_target_value(new Variant.string("Refresh Not implemented"));

            Gtk.Menu menu = new Gtk.Menu ();
            Gtk.MenuItem import_opml = new Gtk.MenuItem.with_label("Import OPML File");
            menu.add(import_opml);
            Granite.Widgets.AppMenu appmenu = new Granite.Widgets.AppMenu (menu);
            this.pack_end (appmenu);

            Gtk.Revealer r_search_btn = new Gtk.Revealer ();
            Gtk.Revealer r_search = new Gtk.Revealer ();
            r_search_btn.set_reveal_child (true);
            r_search_btn.set_transition_type
                (Gtk.RevealerTransitionType.SLIDE_LEFT);
            r_search.set_transition_type
                (Gtk.RevealerTransitionType.SLIDE_LEFT);
            Gtk.Image search_img = new Gtk.Image.from_icon_name
                ("edit-find", Gtk.IconSize.LARGE_TOOLBAR);
            Gtk.ToolButton search_btn = new Gtk.ToolButton (search_img, null);
            search_btn.clicked.connect (() => {
                r_search_btn.set_reveal_child (false);
                r_search.set_reveal_child (true);
            });
            r_search_btn.add (search_btn);
            this.pack_end (r_search_btn);

            Gtk.SearchEntry search = new Gtk.SearchEntry ();
            r_search.add (search);
            this.pack_end (r_search);
        }


    }

}
