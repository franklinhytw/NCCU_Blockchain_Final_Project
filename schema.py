from marshmallow import Schema, fields, ValidationError

class AddProductSchema(Schema):
    productId = fields.String(required=True)
    name = fields.String(required=True)
    description = fields.String(required=True)
    producer = fields.String(required=True)
    location = fields.String(required=True)

class AddProductComponentSchema(Schema):
    productId = fields.String(required=True)
    componentId = fields.String(required=True)
    name = fields.String(required=True)
    description = fields.String(required=True)
    producer = fields.String(required=True)
    location = fields.String(required=True)
    componentType = fields.String(required=True)