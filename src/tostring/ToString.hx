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
                expr: macro $b{generateImpl(baseFields, fields, options)},
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
        baseFields: Array<ClassField>,
        buildFields: Array<Field>,
        options: MacroOptions,
    ): Array<Expr> {

        // First, let's filter out the fields that we will not use
        baseFields = baseFields.filter(field -> {
            if (field.meta.has(":tostring.exclude"))
                return false;
            return switch (field.kind) {
                case FVar(read, _) if (read != AccNever):
                    true;
                default:
                    false;
            }
        });
        buildFields = buildFields.filter(field -> {
            final meta = field.meta;
            if (meta != null && meta.exists(m -> m.name == ":tostring.exclude"))
                return false;
            return switch (field.kind) {
                case FVar(_, _):
                    true;
                case FProp(get, _, _, _) if (get != "never"):
                    true;
                default:
                    false;
            }
        });

        // Empty classes have the same representation in either mode
        final localClass = Context.getLocalClass().get();
        final className = localClass.name;
        if (baseFields.length + buildFields.length == 0) {
            return [macro return $v{className} + " { }"];
        }

        return if (options.pretty) {
            generateImplPretty(baseFields, buildFields, options);
        } else {
            generateImplNormal(baseFields, buildFields, options);
        }
    }

    private static function generateImplNormal(
        baseFields: Array<ClassField>,
        buildFields: Array<Field>,
        options: MacroOptions,
    ): Array<Expr> {
        final exprs: Array<Expr> = [];
        exprs.push(macro final buf = new StringBuf());
        final localClass = Context.getLocalClass().get();
        final className = localClass.name;
        exprs.push(macro buf.add($v{className}));
        exprs.push(macro buf.add(" { "));

        final fieldCount = baseFields.length + buildFields.length;
        var currentIndex = 1;

        function pushField(name: String) {
            exprs.push(macro buf.add($v{name}));
            exprs.push(macro buf.add(": "));
            exprs.push(macro buf.add((this.$name)));
            if (currentIndex < fieldCount) {
                exprs.push(macro buf.add(", "));
            }
            currentIndex += 1;
        }

        for (baseField in baseFields) {
            pushField(baseField.name);
        }

        for (buildField in buildFields) {
            pushField(buildField.name);
        }

        exprs.push(macro buf.add(" }"));
        exprs.push(macro return buf.toString());
        return exprs;
    }

    private static function generateImplPretty(
        baseFields: Array<ClassField>,
        buildFields: Array<Field>,
        options: MacroOptions,
    ): Array<Expr> {
        final exprs: Array<Expr> = [];
        exprs.push(macro final buf = new tostring.PrettyBuf());
        final localClass = Context.getLocalClass().get();
        final className = localClass.name;
        exprs.push(macro buf.add($v{className}));
        exprs.push(macro buf.addLine(" {"));
        exprs.push(macro buf.increaseIndent());

        final fieldCount = baseFields.length + buildFields.length;
        var currentIndex = 1;

        function pushField(name: String) {
            exprs.push(macro buf.add($v{name}));
            exprs.push(macro buf.add(": "));
            exprs.push(macro buf.add(Std.string(this.$name)));
            if (currentIndex < fieldCount) {
                exprs.push(macro buf.addLine(","));
            } else {
                exprs.push(macro buf.addLine());
            }
            currentIndex += 1;
        }

        for (baseField in baseFields) {
            pushField(baseField.name);
        }

        for (buildField in buildFields) {
            pushField(buildField.name);
        }

        exprs.push(macro buf.decreaseIndent());
        exprs.push(macro buf.add("}"));
        exprs.push(macro return buf.toString());
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
