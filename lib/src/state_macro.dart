import 'dart:async';

import 'package:macros/macros.dart';

macro class StateClass implements ClassDeclarationsMacro {
  const StateClass();

  @override
  FutureOr<void> buildDeclarationsForClass(
    ClassDeclaration clazz,
    MemberDeclarationBuilder builder,
  ) async {
    final fields = await builder.fieldsOf(clazz);

    for (final field in fields) {
      await _addGetterSetter(field, builder);
    }
  }

  Future<void> _addGetterSetter(
    FieldDeclaration field,
    MemberDeclarationBuilder builder,
  ) async {
    final name = field.identifier.name;
    final isPublic = !name.startsWith('_');

    final ignore = [field.hasConst, field.hasFinal, field.hasStatic, isPublic];

    if (ignore.any((e) => e)) {
      return;
    }
    final metadata = field.metadata;

    for (final m in metadata) {
      if (m is IdentifierMetadataAnnotation &&
          m.identifier.name.toLowerCase() == 'stateignore') {
        return;
      }
    }

    final typeParts = await field.typeParts(builder);

    final fieldName = name.substring(1);

    builder.declareInType(
      DeclarationCode.fromParts(
        [
          '\t',
          ...typeParts,
          ' get ',
          fieldName,
          ' => _',
          fieldName,
          ';\n',
        ],
      ),
    );

    builder.declareInType(DeclarationCode.fromParts([
      '\t',
      'set ',
      fieldName,
      '(',
      ...typeParts,
      ' value) {\n\t\t',
      'setProperty(() {\n\t\t\t',
      '_',
      fieldName,
      ' = value;\n\t\t',
      '});\n\t',
      '}\n',
    ]));
  }
}

const stateIgnore = StateIgnore();

class StateIgnore {
  const StateIgnore();
}

extension on FieldDeclaration {
  Future<List> typeParts(MemberDeclarationBuilder builder) async {
    final type = this.type;
    if (type is! NamedTypeAnnotation) {
      builder.report(
        Diagnostic(
          DiagnosticMessage(
              'using dynamic type for "${identifier.name}" because real type is not provided'),
          Severity.warning,
        ),
      );

      return ['dynamic'];
    }

    final parts = [];
    for (final e in type.code.parts) {
      switch (e) {
        case NamedTypeAnnotationCode():
          parts.add((await builder.typeDeclarationOf(e.name)).identifier);
        default:
          parts.add(e);
      }
    }

    return parts;
  }
}
