package tostring;

import buddy.BuddySuite;
import utest.Assert;

using StringTools;

class PrettyBufSuite extends BuddySuite {
    public function new() {
        describe("PrettyBuf", () -> {

            it("does not break lines/indent when not necessary", () -> {
                final buf = new PrettyBuf();
                buf.add("abc");
                buf.add("123");
                buf.add("def");
                Assert.equals("abc123def", buf.toString());
            });

            it("correctly applies indentation", () -> {

                final innerBuf = new PrettyBuf();
                innerBuf.addLine("{");
                innerBuf.increaseIndent();
                innerBuf.addLine("\"baz\": \"quox\"");
                innerBuf.decreaseIndent();
                innerBuf.add("}");

                final buf = new PrettyBuf();
                buf.addLine("{");
                buf.increaseIndent();
                buf.addLine("\"foo\": 2,");
                buf.add("\"bar\": ");
                buf.addMultiline(innerBuf.toString());
                buf.popToken();
                buf.addLine();
                buf.decreaseIndent();
                buf.add("}");

                Assert.equals("{\n  \"foo\": 2,\n  \"bar\": {\n    \"baz\": \"quox\"\n  }\n}",
                    buf.toString());
            });

            it("correctly splits multiline text", () -> {

                // Multiple CRLF line breaks in the middle insert an empty line
                final buf = new PrettyBuf();
                buf.addMultiline("aaa\r\nb\r\n\r\ncc");
                Assert.equals("aaa\nb\n\ncc\n", buf.toString());

                // The same happens also with LF only
                buf.clear();
                buf.addMultiline("aaa\nb\n\ncc");
                Assert.equals("aaa\nb\n\ncc\n", buf.toString());

                // A single line break at the end does not change the result
                buf.clear();
                buf.addMultiline("aaa\r\nb\r\n\r\ncc\r\n");
                Assert.equals("aaa\nb\n\ncc\n", buf.toString());

                // Ditto
                buf.clear();
                buf.addMultiline("aaa\nb\n\ncc\n");
                Assert.equals("aaa\nb\n\ncc\n", buf.toString());

                // However, ending with more than one line break inserts empty lines
                buf.clear();
                buf.addMultiline("aaa\r\nb\r\n\r\ncc\r\n\r\n");
                Assert.equals("aaa\nb\n\ncc\n\n", buf.toString());

                // Ditto
                buf.clear();
                buf.addMultiline("aaa\nb\n\ncc\n\n");
                Assert.equals("aaa\nb\n\ncc\n\n", buf.toString());
            });
        });
    }
}
