package;

import benched.Benched;

class BenchmarkMain {
    public static function main() {
        final benched = new Benched(0.25, 30, false);
        final bench = new SplitBenchmark();

        benched.benchmark("multilineWithDelimiter (split-based)", bench.multilineWithDelimiter);
        benched.benchmark("multiline (default impl, charcode-based)", bench.multiline);
        #if js
        benched.benchmark("multilineJs (regex-based)", bench.multilineJs);
        #end

        Sys.println(benched.generateReport());
    }
}
