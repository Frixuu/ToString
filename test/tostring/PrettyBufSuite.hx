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

                Assert.equals("{
  \"foo\": 2,
  \"bar\": {
    \"baz\": \"quox\"
  }
}".replace("\r\n", "\n"), buf.toString());
            });
        });
    }
}
