package tostring;

import buddy.BuddySuite;
import buddy.SuitesRunner;
import buddy.reporting.ConsoleColorReporter;

final class TestMain {
    private static function main() {

        final suites: Array<BuddySuite> = [];
        suites.push(new PrettyBufSuite());
        suites.push(new ToStringSuite());

        final reporter = new ConsoleColorReporter();
        final runner = new SuitesRunner(suites, reporter);
        runner.run();

        #if sys
        Sys.exit(runner.statusCode());
        #end
    }
}
