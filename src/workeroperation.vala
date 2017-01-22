
namespace Reader {
    public delegate void ConcurrentCallback () throws Error;

    public class WorkerOperation : Object {
        private ConcurrentCallback cb;
        
        public WorkerOperation(ConcurrentCallback cb) {
            this.cb = cb;
        }

        public void execute() {
            try {
                cb();
            } catch (Error e) {
                error(e.message);
            }
        }

        public async void wait_async() throws Error {
            print("No idea what i do here\n");
        }
    }
}
