# `CastorEDC.Model`
[🔗](https://github.com/basbl/ex_castor_edc/blob/1.0.0/lib/castor_edc/model.ex#L1)

The structs responses are decoded into, and the helpers that decode them.

Every response the API documents has a struct under `CastorEDC.Model`,
generated from the same spec as the operations. Nested objects are
decoded into their own structs. A field the spec doesn't name is kept,
under its wire name, in the struct's `extra` map, so a response survives
the API adding a field; `_links` and `_embedded` are left out. A value
the client can't read as its documented type, such as a date in an
unexpected format, stays as it arrived rather than raising.

The generated `new/1` functions decode with this module's helpers, which
aren't part of the public API.

---

*Consult [api-reference.md](api-reference.md) for complete listing*
