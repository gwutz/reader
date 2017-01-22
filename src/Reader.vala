
namespace Reader {

    public class Application : Granite.Application {

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
            default = new Reader.Controller ();
        }

        private Unity.LauncherEntry? entry = null;

        public Application () {
            Object(application_id: "org.pantheon.reader",
                   flags: ApplicationFlags.FLAGS_NONE);
            _instance = this;
            controller.add_actions();
        }

        protected override void activate () {
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
