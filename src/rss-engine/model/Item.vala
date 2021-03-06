/* Item.vala
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

    public class Item : Object {
        public string id { get; set; }
        public string title { get; set; }
        public string content { get; set; }
        public string pub_date { get; set; }
        public DateTime date {
            owned get {
                var locale = Intl.setlocale ();
                Intl.setlocale (LocaleCategory.TIME, "C");
                Time t = Time();
                t.strptime(pub_date, "%a, %d %b %Y %H:%M:%S +0000");
                Intl.setlocale (LocaleCategory.TIME, locale);
                return new DateTime.local (1900 + t.year, 1 + t.month, t.day, t.hour, t.minute, (double)t.second);
            }
        }

        public string to_string() {
            return "Item [id=%s, title=%s]".printf(id, title);
        }
    }

}
