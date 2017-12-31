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
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
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

namespace ShowMyPictures.Services {
    public class LibraryManager : GLib.Object {
        Settings settings;

        static LibraryManager _instance = null;
        public static LibraryManager instance {
            get {
                if (_instance == null) {
                    _instance = new LibraryManager ();
                }
                return _instance;
            }
        }

        public signal void added_new_album (ShowMyPictures.Objects.Album album);

        public Services.DataBaseManager db_manager { get; construct set; }
        public Services.LocalFilesManager lf_manager { get; construct set; }

        public GLib.List<Objects.Album> albums {
            get {
                return db_manager.albums;
            }
        }

        construct {
            settings = ShowMyPictures.Settings.get_default ();

            lf_manager = Services.LocalFilesManager.instance;
            lf_manager.found_image_file.connect (found_local_image_file);

            db_manager = Services.DataBaseManager.instance;
        }

        private LibraryManager () { }

        public async void sync_library_content () {
            new Thread <void*> (null, () => {
                //remove_non_existent_items ();
                scan_local_library_for_new_files (settings.library_location);
                return null;
            });
        }

        public void found_local_image_file (string path) {
            new Thread<void*> (null, () => {
                if (!db_manager.picture_file_exists (path)) {
                    insert_picture_file (path);
                }
                return null;
            });
        }

        public void scan_local_library_for_new_files (string path) {
            lf_manager.scan (path);
        }

        private void insert_picture_file (string path) {
            int year = 0;
            int month = 0;
            int day = 0;

            var file = File.new_for_path (path);
            FileInfo info = file.query_info ("standard::*,time::*", 0);
            var attributes = info.list_attributes (null);
            if (attributes != null) {
                uint64 modified = info.get_attribute_uint64 ("time::modified");
                if (modified > 0) {
                    var date_time = new DateTime.from_unix_local ((int64)modified);
                    year = date_time.get_year ();
                    month = date_time.get_month ();
                    day = date_time.get_day_of_month ();
                }
            }

            var album = new Objects.Album (Utils.get_default_album_title (year, month, day));
            album.year = year;
            album.month = month;
            album.day = day;

            album = db_manager.insert_album_if_not_exists (album);
            var picture = new Objects.Picture ();
            picture.path = path;
            picture.year = year;
            picture.month = month;
            picture.day = day;
            picture.mime_type = info.get_content_type ();

            album.add_picture_if_not_exists (picture);
        }
    }
}
