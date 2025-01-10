# Javascript Expressions in FHIR

FHIR supports different types of of expression logic: [fhirpath](https://www.hl7.org/fhirpath/) and [CQL](https://build.fhir.org/ig/HL7/cql/) and [FML](https://www.hl7.org/fhir/mapping-language.html). 

The downside of these specialized languages is that they depend on specific libraries. It also requires authors to understand these languages. This makes them more cumbersome to use. An alternative to these specialized languages would be a commonly available, well accepted programming language that can be run (safely) in many different environments. A prime example of such language is [javascript](https://en.wikipedia.org/wiki/JavaScript).

This implementation guide extends FHIR with support for javascript based expressions.

## javascript profile

Javascript is a powerful languages with many features and capabilities. In order to allows for safe execution of untrusted code in when evaluating javascript expressions, the language is restricted.


### Allowed functions

The javascript is restricted to the following commands:
> "self", "__proto__", "__defineGetter__", "__defineSetter__", "__lookupGetter__", "__lookupSetter__",
> "constructor", "hasOwnProperty", "isPrototypeOf", "propertyIsEnumerable",
> "toLocaleString", "toString",
> "Array", "Boolean", "Date", "Function", "Object", "String", "undefined",
> "Infinity", "isFinite", "isNaN",
> "Math",  "NaN", "Number", "parseFloat", "parseInt",
> "RegExp"

### FHIRpath support

In addition, evaluation of FHIRpath expression is allowed using the following expression:
>    FHIRpath.evaluate( base, expression )

Upon execution, all variables available to FHIRpath and CQL expressions are provided on `ENV`.

I.e. when running these expressions from an SDC questionnaire the following context variables are available:

| Variable | description |
|----|---| 
| `ENV.resource` | Corresponds to `%resource` and refers to the QuestionnaireResponse |
| `ENV.questionnaire` | Relates to the current Questionnaire resource |

### Libraries

It is possible to use Javascript libraries. These are defined as FHIR Library resources (see ...). The Library can contain javascript or refer to a file where the javascript can be downloaded from.

### Defining and executing javascript

The field Expression.expression will hold the javascript expression to be executed. When the expression refers to functions, these have to be defined in a Library resource.

The content of a library resources is concatenated to the expression logic. The complete file is executed.
