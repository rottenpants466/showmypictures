/*-
 * Copyright (c) 2018-2018 Artem Anufrij <artem.anufrij@live.de>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 *
 * The Noise authors hereby grant permission for non-GPL compatible
 * GStreamer plugins to be used and distributed together with GStreamer
 * and Noise. This permission is above and beyond the permissions granted
 * by the GPL license by which Noise is covered. If you modify this code
 * you may extend this exception to your version of the code, but you are not
 * obligated to do so. If you do not wish to do so, delete this exception
 * statement from your version.
 *
 * Authored by: Artem Anufrij <artem.anufrij@live.de>
 */

namespace ShowMyPictures.Widgets {
    public class NavigationDate : Granite.Widgets.SourceList.ExpandableItem, Granite.Widgets.SourceListSortable {

        public int val { get; private set; default = 0; }

        construct {
            this.child_removed.connect ((child) => {
                if (this.children.size == 0) {
                    this.parent.remove (this);
                }
            });
        }

        public NavigationDate (string title, int val) {
            this.name = title;
            this.val = val;
        }

        public NavigationDate get_subfolder (Objects.Album album) {
            foreach (var child in this.children) {
                if (child is Widgets.NavigationDate) {
                    var folder = child as Widgets.NavigationDate;
                    if (folder.val == album.month) {
                        return folder;
                    }
                }
            }
            var new_child = new Widgets.NavigationDate (Utils.get_month_name (album.month), album.month);
            this.add (new_child);
            return new_child;
        }

        public int compare (Granite.Widgets.SourceList.Item a, Granite.Widgets.SourceList.Item b) {
            if (a is NavigationDate && b is NavigationDate) {
                return (b as NavigationDate).val - ((a as NavigationDate).val);
            }
            return 0;
        }

        public bool allow_dnd_sorting () {
            return false;
        }
    }
}
