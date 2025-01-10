Profile: JavascriptStructureMap
Parent: StructureMap
Description: "StructureMap using javascript"
* insert StructureDefinitionMetadata
* structure 0..0
* import 0..0
* extension contains http://hl7.org/fhir/StructureDefinition/cqf-library named library 0..* MS
* group 1..*
  * extends 0..0  
  // input as normal
  * rule 1..1 // ignored
    * source 1..1
      * context 1..1
      * context = "ignored"
      * min 0..0
      * max 0..0
      * type 0..0
      * defaultValue[x] 0..0
      * element 0..0
      * listMode 0..0
      * variable 0..0
      * condition 0..0
      * check 0..0 
      * logMessage 0..0
    * target 0..0
  * extension contains StructureMapJavascriptExtension named javascript 1..1 MS

Extension: StructureMapJavascriptExtension
Id: javascript-structuremap
Title: "Structuremap javascript extension."
Description: """
    Provides a javascript extension that is to executed. The expression will return a transformed resource.
"""
* insert StructureDefinitionMetadata
* value[x] only JavascriptExpression