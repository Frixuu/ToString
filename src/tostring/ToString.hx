package tostring;

#if macro
import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Type.ClassType;
import haxe.macro.Context;
import haxe.macro.Expr.Field;

using Lambda;
#end

/**
    Utilities for auto-generating `toString` class methods.
**/
@:nullSafety(Off)
final class ToString {

    /**
        If applied as a build macro,
        generates a `toString` method that prints a class' fields.
    **/
    public static macro function generate(?options: MacroOptions): Array<Field> {

        options = options == null ? {} : options;
        options.pretty = options.pretty == null ? false : options.pretty;

        final pos = Context.currentPos();
        final fields = Context.getBuildFields();
        if (fields.exists(f -> f.name == "toString")) {
            Context.error("Class already defines a field called \"toString\"", pos);
        }

        final baseFields = getBaseClassFields(Context.getLocalClass().get());
        final isOverride = baseFields.exists(cf -> cf.name == "toString");

        final field: Field = {
            pos: pos,
            name: "toString",
            doc: "Returns a string representation of this object. (auto-generated)",
            meta: [],
            access: isOverride ? [APublic, AOverride] : [APublic],
            kind: FFun({
                params: [],
                args: [],
                ret: (macro : String),
                expr: macro $b{generateImpl(fields, baseFields, options)},
            }),
        };

        fields.push(field);
        return fields;
    }

    #if macro
    /**
        Generates the body of the `toString` method.
    **/
    private static function generateImpl(
        buildFields: Array<Field>,
        baseFields: Array<ClassField>,
        options: MacroOptions,
    ): Array<Expr> {

        final exprs: Array<Expr> = [];
        if (options.pretty) {
            exprs.push(macro final buf = new tostring.PrettyBuf({
                indentStr: "  ",
                newLineStr: "\n"
            }));
        } else {
            exprs.push(macro var buf = new StringBuf());
        }

        final localClass = Context.getLocalClass().get();
        final className = localClass.name;
        exprs.push(macro buf.add($v{className}));
        if (options.pretty) {
            exprs.push(macro buf.add(" {"));
            exprs.push(macro buf.addLine());
            exprs.push(macro buf.increaseIndent());
        } else {
            exprs.push(macro buf.add(" { "));
        }

        var hasAnyField = false;

        function pushField(name: String) {
            exprs.push(macro buf.add($v{name}));
            exprs.push(macro buf.add(": "));
            exprs.push(macro buf.add(Std.string(this.$name)));
            if (options.pretty) {
                exprs.push(macro buf.add(","));
                exprs.push(macro buf.addLine());
            } else {
                exprs.push(macro buf.add(", "));
            }
        }

        for (baseField in baseFields) {

            final meta = baseField.meta;
            if (meta.has(":tostring.exclude")) {
                continue;
            }

            switch (baseField.kind) {
                case FVar(read, _) if (read != AccNever):
                    hasAnyField = true;
                    pushField(baseField.name);
                default:
            }
        }

        for (buildField in buildFields) {

            final meta = buildField.meta;
            if (meta != null && meta.exists(m -> m.name == ":tostring.exclude")) {
                continue;
            }

            switch (buildField.kind) {
                case FVar(_, _):
                    hasAnyField = true;
                    pushField(buildField.name);
                case FProp(get, _, _, _) if (get != "never"):
                    hasAnyField = true;
                    pushField(buildField.name);
                default:
            }
        }

        if (options.pretty) {
            exprs.pop();
            exprs.pop();
            if (hasAnyField) {
                exprs.push(macro buf.decreaseIndent());
                exprs.push(macro buf.addLine());
            }
            exprs.push(macro buf.add("}"));
            exprs.push(macro return buf.toString());
        } else {
            exprs.push(macro var str = buf.toString());
            if (hasAnyField) {
                exprs.push(macro str = str.substr(0, str.length - 2));
                exprs.push(macro return str + " }");
            } else {
                exprs.push(macro str = str.substr(0, str.length - 1));
                exprs.push(macro return str + "}");
            }
        }

        return exprs;
    }

    /**
        Given a `ClassType`, returns all of its fields.
    **/
    private static function getBaseClassFields(classType: ClassType): Array<ClassField> {
        var fields = classType.fields.get().copy();
        final superClass = classType.superClass;
        final superClassType = superClass == null ? null : superClass.t.get();
        if (superClassType != null) {
            fields = fields.concat(getBaseClassFields(superClassType));
        }
        return fields;
    }
    #end
}

/**
    Options for the `ToString.generate()` build macro.
**/
typedef MacroOptions = {
    public var ?pretty: Bool;
}
