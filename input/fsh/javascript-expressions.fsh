Profile: JavascriptEnabledExpression
Parent: Expression
* insert StructureDefinitionMetadata
* language from JavascriptExpressionLanguageValueset

Profile: JavascriptExpression
Parent: JavascriptEnabledExpression
* insert StructureDefinitionMetadata
* language = JavaScriptExpressionCodes#javascript

ValueSet: JavascriptExpressionLanguageValueset
Title: "Javascript and other expression languages"
* insert StructureDefinitionMetadata
* include codes from valueset http://hl7.org/fhir/ValueSet/expression-language
* JavaScriptExpressionCodes#javascript "Javascript"

CodeSystem: JavaScriptExpressionCodes
Title: "Javascript expression code system"
Description: "Codes used in the javascript IG."
* insert StructureDefinitionMetadata
* ^caseSensitive = true
* ^version = "0.1.0"
* ^status = #active
* #javascript "Javascript"
    "A Javascript expressions"

Profile: JavascriptLibrary
Parent: Library
Title: "Javascript Library"
* insert StructureDefinitionMetadata
* url MS
* version MS
* identifier MS
* title MS
* date MS
* content ^slicing.discriminator.type = #value
* content ^slicing.discriminator.path = contentType
* content ^slicing.rules = #open
* content ^slicing.description = "Javascript content"
* content contains javascript 1..*
* content[javascript]
  * contentType = JavaScriptExpressionCodes#javascript
  