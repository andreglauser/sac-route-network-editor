# -*- coding: utf-8-*-
source_name = "route-editor.sqlite"


def main():
    layers = [
        layer
        for layer in QgsProject.instance().mapLayers().values()
        if source_name in layer.source().split("|")[0]
    ]

    for layer in layers:
        print(f"set default field-setting for layer {layer.name()}")
        set_default_fields(layer)


UUID_EXPRESSION = """
if(
	try(to_int("fid"), NULL) IS NULL,
	uuid('WithoutBraces'), --true: new feature
	"id" --false: existing feature
)
"""

USER_EXPRESION = """@user_full_name"""


def set_default_fields(layer):
    default_fields = [
        [index, field]
        for index, field in enumerate(layer.fields())
        if field.name()
        in ("fid", "id", "updated_at", "updated_by", "created_at", "created_by")
    ]

    for i, f in default_fields:
        dv = QgsDefaultValue()
        form_config = layer.editFormConfig()

        if f.name().endswith("_at"):
            dv.setExpression("to_datetime( now() )")

        if f.name().endswith("_by"):
            dv.setExpression(USER_EXPRESION)

        if f.name().startswith("created_"):
            dv.setApplyOnUpdate(False)

        if f.name().startswith("updated_"):
            dv.setApplyOnUpdate(True)

        if f.name() == "id":
            dv.setExpression(UUID_EXPRESSION)
            dv.setApplyOnUpdate(True)

        form_config.setReadOnly(i, True)
        layer.setDefaultValueDefinition(i, dv)
        layer.setEditFormConfig(form_config)


if __name__ in ("__main__", "__console__"):
    main()
