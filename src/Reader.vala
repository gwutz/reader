/* Reader.vala
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

    public class Application : Gtk.Application {

        private uint main_app_window = 0;

        private static Reader.Application _instance = null;
        public static Reader.Application instance {
            get { return _instance; }
            private set {
                assert (_instance == null);
                _instance = value;
            }
        }

        public Reader.Controller controller {
            get;
            private set;
        }

        private Unity.LauncherEntry? entry = null;

        public Application () {
            Object(application_id: "org.pantheon.reader",
                   flags: ApplicationFlags.FLAGS_NONE);
            _instance = this;
        }

        protected override void activate () {
        	controller = new Reader.Controller ();
            controller.add_actions();

            ReaderWindow window = new ReaderWindow (this);
            this.add_window(window);
            this.main_app_window = window.get_id();

            window.set_default_size(1280, 480);

            window.show_all ();

            this.entry =
                Unity.LauncherEntry.get_for_desktop_id("org.pantheon.reader.desktop");
            this.entry.count = 10;
            this.entry.count_visible = true;
        }

        public ReaderWindow get_main_window() {
            return (ReaderWindow)this.get_window_by_id (main_app_window);
        }

    }

    public static void main (string[] args) {
        Reader.Application app = new Reader.Application ();
        app.run(args);
    }

}
