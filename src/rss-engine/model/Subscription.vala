/* Subscription.vala
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

    public class Subscription : Object {
        private List<Item> _items = new List<Item>();
        public string link { get; set; }
        public string title { get; set; }
        public string description { get; set; }
        public string image_url { get; set; }
        public List<weak Item> items {
            owned get { return _items.copy (); }
        }

        public void add_item (Item item) {
            _items.append(item);
        }

        public string to_string () {
            return "Subscription [link=%s, items=%u]".printf(link, _items.length());
        }
    }

}
