
namespace Reader {
    public const int DEFAULT_MAX_THREADS = 4;

    public class Workerpool : Object {
        private ThreadPool<void *>? thread_pool = null;
        private AsyncQueue<BackgroundJob> queue = new AsyncQueue<BackgroundJob>();

        public Workerpool (int max_threads = DEFAULT_MAX_THREADS) {
            try {
                thread_pool = new ThreadPool<void *>.with_owned_data(
                    on_work_ready, max_threads, false
                );
            } catch (ThreadError e) {
                error(e.message);
            }
        }

        private void on_work_ready(void *ignored) {
            var job =queue.pop();
            job.execute();
        }

        public void enqueue (BackgroundJob job) {
            queue.push(job);
            try {
                thread_pool.add(job);
            } catch (ThreadError e) {
                error(e.message);
            }
        }
    }

    public abstract class BackgroundJob : Object {

        public void execute() {
            execute_in_background();
            Idle.add(() => {
                execute_in_main();
                return false;
            });
        }

        public abstract void execute_in_background();
        public abstract void execute_in_main();

    }
}
