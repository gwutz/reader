/* ReaderWindow.vala
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

    public class ReaderWindow : Gtk.ApplicationWindow {

        public Reader.HeaderBar headerbar;
        //private Reader.Welcome  welcome;
        public Reader.Content  content;

        public ReaderWindow (Gtk.Application app) {
            Object (application: app);
            build_header_ui ();
            //this.welcome = new Reader.Welcome (this.headerbar);
            //this.add (this.welcome);
            this.content = new Reader.Content ();
            this.add (content);
        }

        private void add_rss_document (Rss.Document doc) {
            /*if (welcome.get_parent () != null) {
                this.remove (this.welcome);
                this.add (this.content);
                this.content.show_all ();
            }*/
        }

        private void build_header_ui () {
            this.headerbar = new Reader.HeaderBar ();
            this.set_titlebar (headerbar);
        }
    }
}
