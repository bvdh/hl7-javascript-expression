The javascript approach can also be used as a replacement for mapping. A Javascript file to be used for FHIR mapping needs to implement the following function:

```
function transform( source: string, sourceLibrary: Library, supportingLibrary: Library[], content: any )
```

Alternatively, an extended StructureMap resource can be used that holds a javascript extension.

The javascript in this resource returns the mapped data. All source and target variables will be available as ENV.[varname] variables.

The call FHIR.transform( ) can be used to call other StructureMaps.