/* Workerpool.vala
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

        private void on_work_ready (void *ignored) {
            var job = queue.pop ();
            job.execute ();
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
}
