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

    /** Char code of carriage return (the \r character). **/
    private static inline var CR: Int = 13;

    /** Char code of line feed (the \n character). **/
    private static inline var LF: Int = 10;

    #if js
    private static final newLineRegex: js.lib.RegExp = new js.lib.RegExp("\r\n|\n");
    #end

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
        Pushes a new line token to this buffer
        preceding it by the input line, if it is not empty.
    **/
    public final function addLine(line: String = "") {
        if (line.length > 0) {
            this.add(line);
        }
        this.inner.push(NewLine);
    }

    /**
        Splits a provided `String` into lines and adds them to this buffer,
        adding new line and indentation tokens where necessary.

        Note: If you control your input's line endings,
        `addMultilineWithDelimiter` _might_ be faster on your target platform.

        @param text Multiline piece of text to be added to this `PrettyBuf`.
        @param finalNewLine If set to false, will not push a single additional new line character.
        Note: If your `text` ends with new line characters, it might not work like you expect it to.
    **/
    public final function addMultiline(text: String, finalNewLine: Bool = true) {
        #if js
        addMultilineJsImpl(text);
        #else
        addMultilineDefaultImpl(text);
        #end
        if (!finalNewLine) {
            popToken();
        }
    }

    /**
        Splits a `String` into lines and adds them to this buffer, decorating when necessary.

        This implementation parses the input character-by-character.
    **/
    private inline function addMultilineDefaultImpl(s: String) {
        final strLength: Int = s.length;
        var lastEolPos: Int = 0;
        var currentPos: Int = 0;
        var currentCode: Int = StringTools.fastCodeAt(s, currentPos++);
        while (currentPos < strLength) {
            // TODO: this implementation also matches multiple CR chars, which is inconsistent
            if (currentCode == LF || currentCode == CR) {
                if ((currentPos - lastEolPos) > 1 || StringTools.fastCodeAt(s, lastEolPos) == CR) {
                    this.addLine(s.substring(lastEolPos, currentPos - 1));
                }
                lastEolPos = currentPos;
            }
            currentCode = StringTools.fastCodeAt(s, currentPos++);
        }

        if (strLength != lastEolPos) {
            this.addLine(s.substring(lastEolPos));
        }
    }

    #if js
    /**
        Adds a multiline string to this buffer, using built-in Regexp functionality.

        This JS-specific solution seems to be about 2 times faster than the default implementation.
        See the `benches/` directory in the repository.
    **/
    private inline function addMultilineJsImpl(s: String) {
        for (line in s.split(untyped newLineRegex)) {
            this.addLine(line);
        }
    }
    #end

    /**
        Splits a provided `String` into lines using a custom delimiter
        and adds them to this buffer,
        adding new line and indentation tokens where necessary.
    **/
    public final function addMultilineWithDelimiter(text: String, delimiter: String) {
        for (line in text.split(delimiter)) {
            this.addLine(line);
        }
    }

    /**
        Removes the last token from the internal buffer representation, if one exists.
        Can be used for removing trailing commas etc.

        Note: `add`- calls can (and do) generate more than one token.
        This function might NOT undo whole `add`- calls.
    **/
    public final function popToken(): Bool {
        return this.inner.pop() != null;
    }

    /**
        Resets the internal state of this buffer.
    **/
    public final function clear() {
        while (this.popToken()) {}
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
