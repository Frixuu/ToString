package tostring;

/**
    A `StringBuf` replacement aimed at pretty-printing code, JSON
    and other cases that benefit from new lines and indentation.
**/
@:nullSafety(StrictThreaded)
class PrettyBuf {

    /**
        The inner buffer.
    **/
    private var inner: Array<Segment>;

    /**
        Current indentation level.
    **/
    private var currentIndentLevel: Int;

    /**
        Options of the serializer.
    **/
    public var options(default, default): PrettyBufOptions;

    /**
        Creates a new `PrettyBuf`.
    **/
    public function new(?options: PrettyBufOptions) {
        this.inner = [];
        this.currentIndentLevel = 0;
        this.options = options == null ? PrettyBufOptions.DEFAULT : options;
    }

    /**
        Increases the indentation level by one.
    **/
    public final function increaseIndent() {
        this.currentIndentLevel += 1;
    }

    /**
        Decreases the indentation level by one.

        Throws if the buffer's indentation level falls below zero.
    **/
    public final function decreaseIndent() {
        this.currentIndentLevel -= 1;
        if (this.currentIndentLevel < 0) {
            throw "Cannot have negative indentation";
        }
    }

    /**
        Pushes an appropriate amount of indentation blocks to this buffer.
    **/
    private final function addIndentation() {
        for (_ in 0...this.currentIndentLevel) {
            this.inner.push(Indent);
        }
    }

    /**
        Pushes a `String` to this buffer without any processing.
    **/
    public final function add(s: String) {
        final len = this.inner.length;
        if (len > 0 && this.inner[len - 1].match(NewLine)) {
            this.addIndentation();
        }
        this.inner.push(Text(s));
    }

    /**
        Pushes a `String` to this buffer, following it with a new line token.
    **/
    public final function addLine(line: String = "") {
        this.add(line);
        this.inner.push(NewLine);
    }

    /**
        Splits a provided `String` into lines and adds them to this buffer,
        adding new line and indentation tokens.
    **/
    public final function addMultiline(s: String, delimiter: String = "\n") {
        for (line in s.split(delimiter)) {
            this.addLine(line);
        }
    }

    /**
        Removes the last token from the internal buffer representation, if one exists.
        Can be used for removing trailing commas etc.

        Note: `add`- calls can (and do) generate more than one token.
        This function might NOT undo whole `add`- calls.
    **/
    public final function pop(): Bool {
        return this.inner.pop() != null;
    }

    /**
        Resets the internal state of this buffer.
    **/
    public final function clear() {
        while (this.pop()) {}
        this.currentIndentLevel = 0;
    }

    /**
        Serializes contents of this buffer to a string.

        This operation does not reset this buffer afterwards.
    **/
    public function toString() {

        final indentStr = this.options.indentStr;
        final newLineStr = this.options.newLineStr;

        // TODO: reuse the StringBuf? maybe rent it from a pool?
        final buf = new StringBuf();
        for (segment in this.inner) {
            buf.add(switch (segment) {
                case Text(s):
                    s;
                case Indent:
                    indentStr;
                case NewLine:
                    newLineStr;
            });
        }

        return buf.toString();
    }
}

/**
    Options for a `PrettyBuf` instance.
**/
@:structInit
class PrettyBufOptions {

    /**
        The default `PrettyBuf` options.
    **/
    public static final DEFAULT: PrettyBufOptions = {};

    /**
        A `String` representation of a single indentation level.
        Typically is comprised only of whitespace.
    **/
    public var indentStr(default, null): String = "  ";

    /**
        A `String` representation of a new line token.
        Typically LF, CR or both.
    **/
    public var newLineStr(default, null): String = "\n";
}

/**
    The internal model of the `PrettyBuf`.
**/
private enum Segment {
    Text(s: String);
    Indent;
    NewLine;
}
