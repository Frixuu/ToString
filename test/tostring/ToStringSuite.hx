package tostring;

import buddy.BuddySuite;
import utest.Assert;

using StringTools;

class ToStringSuite extends BuddySuite {
    public function new() {
        describe("ToString", () -> {
            it("should correctly print empty classes", () -> {
                final normal = new EmptyNormal();
                Assert.equals("EmptyNormal { }", normal.toString());
                final empty = new EmptyPretty();
                Assert.equals("EmptyPretty { }", empty.toString());
            });
            it("should correctly print normal classes", () -> {
                final normal = new Normal();
                Assert.equals("Normal { privateField: 1, publicField: null, publicProperty: three, publicGetter: 4, normalOnly: 7 }",
                    normal.toString());
            });
            it("should correctly print pretty classes", () -> {
                final pretty = new Pretty();
                Assert.equals("Pretty {
  privateField: 1,
  publicField: null,
  publicProperty: three,
  publicGetter: 4,
  prettyOnly: 8
}".replace("\r", ""), pretty.toString());
            });
        });
    }
}

@:build(tostring.ToString.generate())
class EmptyNormal {
    public function new() {}
}

@:build(tostring.ToString.generate({pretty: true}))
class EmptyPretty {
    public function new() {}
}

class Base {
    public static var PUBLIC_STATIC: String = "I'm a static!";

    private var privateField: Int = 1;

    public var publicField: Null<Dynamic> = null;
    public var publicProperty(default, default): String = "three";
    public var publicGetter(get, never): Int;

    public function get_publicGetter(): Int {
        return 4;
    }

    public var publicSetOnly(never, default): Int = 5;

    @:tostring.exclude
    public var excluded: Int = 6;

    public function publicMethod(x: Int): Int {
        return x * 2;
    }
}

@:build(tostring.ToString.generate())
class Normal extends Base {
    public var normalOnly: Int = 7;

    public function new() {}
}

@:build(tostring.ToString.generate({pretty: true}))
class Pretty extends Base {
    public var prettyOnly: Int = 8;

    public function new() {}
}
