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
                expr: macro $b{generateImpl(fields, baseFields)},
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
        baseFields: Array<ClassField>
    ): Array<Expr> {

        final exprs: Array<Expr> = [];
        exprs.push(macro final buf = new tostring.PrettyBuf({indentStr: "", newLineStr: " "}));

        final localClass = Context.getLocalClass().get();
        final className = localClass.name;
        exprs.push(macro buf.add($v{className}));
        exprs.push(macro buf.add(" {"));
        exprs.push(macro buf.addLine());
        exprs.push(macro buf.increaseIndent());

        var hasAnyField = false;

        function pushField(name: String) {
            exprs.push(macro buf.add($v{name}));
            exprs.push(macro buf.add(": "));
            exprs.push(macro buf.add(Std.string(this.$name)));
            exprs.push(macro buf.add(","));
            exprs.push(macro buf.addLine());
        }

        for (baseField in baseFields) {
            switch (baseField.kind) {
                case FVar(read, _) if (read != AccNever):
                    hasAnyField = true;
                    pushField(baseField.name);
                default:
            }
        }

        for (buildField in buildFields) {
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

        if (hasAnyField) {
            exprs.pop(); // new line
            exprs.pop(); // trailing comma
        }

        exprs.push(macro buf.decreaseIndent());
        exprs.push(macro buf.addLine());
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
