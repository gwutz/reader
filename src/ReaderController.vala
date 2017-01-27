/* ReaderController.vala
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
    public const string READER_ERROR = "ReaderShowError";
    public const string READER_ADD_URL = "ReaderAddUrl";
    public const string READER_REFRESH = "ReaderRefresh";

    public class Controller : Object {
        private Reader.Engine.Fetcher fetcher { get; set; default = new Reader.Engine.Fetcher (); }

        public Controller () {
            fetcher.engine_error.connect (show_error);
        }

        public void add_actions () {
            var show_error = new SimpleAction(READER_ERROR,
                                              VariantType.STRING);
            show_error.activate.connect ((val) => {
                this.show_error(val.get_string());
            });

            var add_url = new SimpleAction(READER_ADD_URL, VariantType.STRING);
            add_url.activate.connect ((val) => {
            	fetcher.add_subscription (val.get_string ());
            });

            var refresh = new SimpleAction (READER_REFRESH, null);
            refresh.activate.connect (() => {
                fetcher.refresh_manual ();
            });

            Reader.Application.instance.add_action(show_error);
            Reader.Application.instance.add_action(add_url);
            Reader.Application.instance.add_action(refresh);
        }

        public void show_error (string message) {
            var window = Reader.Application.instance.get_main_window ();
            Gtk.InfoBar info_bar = window.content.info_bar;
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

        public Reader.Engine.Item? get_item (string id) {
            return Reader.Engine.Fetcher.instance.get_item (id);
        }

        public Reader.Engine.Subscription? get_subscription (string id) {
            return Reader.Engine.Fetcher.instance.get_subscription (id);
        }
    }

}
