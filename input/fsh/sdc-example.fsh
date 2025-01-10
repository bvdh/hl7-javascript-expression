

Instance: BMI
InstanceOf: Questionnaire
* meta
  * profile[+] = "http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-pop-obsn"
  * profile[+] = "http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-extr-obsn"
  * profile[+] = "http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-render"
* url = "http://research.philips.com/fhirplayground/r4/sdc/Questionnaire/bmi-example"
* status = #active
* title = "BMI example"
* description = """
    Prepopulates height and weight based on data in the repository\nbased on Observations in the repository. BMI is calculated and presented\n
    when weight and height are present. When stored, weight and height observations\n
    are created/updated and a BMI observation is added.
"""
* publisher = "Philips IP&S"
* insert sdcQuestionnaireLaunchContext( "launchPatient", #Patient ,"Patient the questionnaire is about." )
* item[+]
  * linkId = "weight"
  * text = "Body weight"
  * type = #decimal
  * code = http://loinc.org#29463-7 "Weight"
  * required = true
  * extension[+]
    * url = "http://hl7.org/fhir/StructureDefinition/questionnaire-unit"
    * valueCoding = http://unitsofmeasure.org#kg
  * extension[+]
    * url = "http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-observationExtract"
    * valueBoolean = true
  * extension[+]
    * url = "http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-observationLinkPeriod"
    * valueDuration
      * value = 1
      * unit = "week"
      * code = #wk
      * system = "http://unitsofmeasure.org"
* item[+]
  * linkId = "height"
  * text = "Body height"
  * type = #decimal
  * code = http://loinc.org#8302-2 "Height"
  * required = true
  * extension[+]
    * url = "http://hl7.org/fhir/StructureDefinition/questionnaire-unit"
    * valueCoding = http://unitsofmeasure.org#m
  * extension[+]
    * url = "http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-observationExtract"
    * valueBoolean = true
  * extension[+]
    * url = "http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-observationLinkPeriod"
    * valueDuration
      * value = 1
      * unit = "year"
      * code = #a
      * system = "http://unitsofmeasure.org"
* item[+]
  * linkId = "bmi"
  * type = #decimal
  * extension[+]
    * url = "http://hl7.org/fhir/StructureDefinition/questionnaire-unit"
    * valueCoding = http://unitsofmeasure.org#kg/m2
  * extension[+]
    * url = "http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-observationExtract"
    * valueBoolean = true
  * insert fhirPathVariable( "height", [["%resource.item.where(linkId='height').answer.value"]] )
  * insert fhirPathVariable( "weight", [["%resource.item.where(linkId='weight').answer.value"]] )
  * insert calculatedJavscriptExpression( [["Math.round(100*(ENV.weight/(ENV.height^2)))/100"]] )
  * readOnly = true
  * text = "Body Mass index (BMI)"
  * code = http://loinc.org#39156-5 "BMI"
  * required = true
* extension[+][JavascriptTargetExpression]
  * valueExpression
    * language = JavaScriptExpressionCodes#javascript
    * expression = """
  createBundle();

  function createBundle(){

    let resTemplate = {
        resourceType: 'Bundle',
        type: 'transaction',
        entry: [
            {
                fullUrl: 'questionnaire-response',
                resource: ENV.resource,
                request: {
                    method: "POST",
                    url: "QuestionnaireResponse"
                }
            },
            {
                fullUrl: 'height',
                resource: createHeightObservation(),
                request: {
                    method: "POST",
                    url: "Observation"
                }
            },
            {
                fullUrl: 'height',
                resource: createWeightObservation(),
                request: {
                    method: "POST",
                    url: "Observation"
                }
            },
            {
                fullUrl: 'bmi',
                resource: createWeightObservation(),
                request: {
                    method: "POST",
                    url: "Observation"
                }
            },
            {
                fullUrl: 'provenance',
                resource: createProvenance(),
                request: {
                    method: "POST",
                    url: "Provenance"
                }
            }

        ]
    }
  }

  function createHeightObservation(){
      let obs =  {
              resourceType: 'Observation',
              active: true,
              status: `final`,
              category:[
                  {
                      "coding": [
                      {
                          "system": "http://terminology.hl7.org/CodeSystem/observation-category",
                          "code": "vital-signs",
                          "display": "Vital Signs"
                      }
                      ]
                  }
              ],
              derivedFrom: {
                  reference:  "questionnaire-response"
              },
              code: FHIR.fhirpath( ENV.resource, '%resource.item.where(linkId=\'height\')' ),
              subject: ENV.resource.subject,
              issued: FHIR.fhirpath( ENV.resource, 'now()'),
              effectiveDateTime: FHIR.fhirpath( ENV.resource, 'now()'),
              performer: ENV.resource.author,
              valueQuantity: {
                  value: ENV.height,
                  unit: 'm',
                  code: 'm',
                  system: 'http://unitsofmeasure.org'
              }

          }
      return obs;
  }


  function createWeightObservation(){
      let obs =     
      {
          resourceType: 'Observation',
          active: true,
          status: `final`,
          category:[
              {
                  "coding": [
                  {
                      "system": "http://terminology.hl7.org/CodeSystem/observation-category",
                      "code": "vital-signs",
                      "display": "Vital Signs"
                  }
                  ]
              }
          ],
          code: FHIR.fhirpath( ENV.resource, '%resource.item.where(linkId=\'weight\')' ),
          derivedFrom: {
              reference:  "questionnaire-response"
          },       
          subject: ENV.resource.subject,
          issued: FHIR.fhirpath( ENV.resource, 'now()'),
          performer: ENV.resource.author,
          valueQuantity: {
              value: ENV.height,
              unit: 'kg',
              code: 'kg',
              system: 'http://unitsofmeasure.org'
          }

      }
      return obs;
  }

  function createBmiObservation(){
      let obs =         
      {
          resourceType: 'Observation',
          active: true,
          status: `final`,
          category:[
              {
                  "coding": [
                  {
                      "system": "http://terminology.hl7.org/CodeSystem/observation-category",
                      "code": "vital-signs",
                      "display": "Vital Signs"
                  }
                  ]
              }
          ],
          derivedFrom: [
              { reference:  "questionnaire-response" },
              { reference:  "weight" },
              { reference:  "height" },
          ],
          code: {
              "coding": [
                  {
                  "system": "http://loinc.org",
                  "code": "39156-5",
                  "display": "Body mass index (BMI) [Ratio]"
                  }
              ],
              "text": "BMI"
              },
          subject: ENV.resource.subject,
          issued: FHIR.fhirpath( ENV.resource, 'now()'),
          effectiveDateTime: FHIR.fhirpath( ENV.resource, 'now()')[0],
          performer: ENV.resource.author,
          valueQuantity: {
              value: FHIR.fhirpath( ENV.resource, '%resource.item.where(linkId=\'bmi\').value'),
              unit: 'kg/m^2',
              code: 'kg/m^2',
              system: 'http://unitsofmeasure.org'
          }
      }
      return obs;
  }


  function createProvenance(){
      let provenance =         {
          resourceType: 'Provenance',
          id: 'provenance',
          occurredPeriod: {
              start: ENV.resource.authored,
              end: FHIR.fhirpath( ENV.resource, 'now()')[0]
          },
          recorded: FHIR.fhirpath( ENV.resource, 'now()')[0],
          agent: [
              {
                  type: {
                      system: "http://terminology.hl7.org/CodeSystem/provenance-participant-type", 
                      code: "enterer", 
                      display: "Enterer"
                  },
                  who: ENV.resource.author
              }
          ],
          target: [
              {
                  extension:[
                      {   url: 'http://hl7.org/fhir/StructureDefinition/resolve-as-version-specific',
                          valueBoolean: true

                      }
                  ],
                  reference: 'questionnaire-response'
              },
              {
                  extension:[
                      {   url: 'http://hl7.org/fhir/StructureDefinition/resolve-as-version-specific',
                          valueBoolean: true

                      }
                  ],
                  reference: 'height'
              },
              {
                  extension:[
                      {   url: 'http://hl7.org/fhir/StructureDefinition/resolve-as-version-specific',
                          valueBoolean: true

                      }
                  ],
                  reference: 'weight'
              },
              {
                  extension:[
                      {   url: 'http://hl7.org/fhir/StructureDefinition/resolve-as-version-specific',
                          valueBoolean: true

                      }
                  ],
                  reference: 'bmi'
              }    
          ]   
      }
  }
"""


RuleSet: enableWhenFhirPathExpression( fpExpression )
* extension[+]
  * url = "http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-enableWhenExpression"
  * valueExpression
    * language = #text/fhirpath
    * expression = { fpExpression }

RuleSet: setHidden( isHidden )
* extension[+]
  * url = "http://hl7.org/fhir/StructureDefinition/questionnaire-hidden"
  * valueBoolean = {isHidden}

RuleSet: initialFhirPathExpression( expression )
* extension[+]
  * url = "http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-initialExpression"
  * valueExpression
    * language = #text/fhirpath
    * expression = {expression}

RuleSet: referenceResource( resourceType )
* extension[+]
  * url = "http://hl7.org/fhir/StructureDefinition/questionnaire-referenceResource"
  * valueCode = {resourceType}

RuleSet: variable( name, language, expression )
* extension[+]
  * url = "http://hl7.org/fhir/StructureDefinition/variable"
  * valueExpression
    * name = {name}
    * language = {language}
    * expression = {expression}

RuleSet: fhirPathVariable( name, expression )
* extension[+]
  * url = "http://hl7.org/fhir/StructureDefinition/variable"
  * valueExpression
    * name = {name}
    * language = #text/fhirpath
    * expression = {expression}

RuleSet: calculatedFhirPathExpression( expression )
* extension[+]
  * url = "http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-calculatedExpression"
  * valueExpression
    * language  = #text/fhirpath
    * expression = {expression}

RuleSet: calculatedJavscriptExpression( expression )
* extension[+]
  * url = "http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-calculatedExpression"
  * valueExpression
    * language  = JavaScriptExpressionCodes#javascript
    * expression = {expression}

RuleSet: renderingStyleSensitive( apply )
* extension[+].url = "http://hl7.org/fhir/StructureDefinition/rendering-styleSensitive"
* extension[=].valueBoolean = {apply}

RuleSet: renderingXhtml( xhtml )
* extension[+].
  * url = "http://hl7.org/fhir/StructureDefinition/rendering-xhtml"
  * valueString = {xhtml}

RuleSet: fhirpathCqfExpression( expression )
* extension[+]
  * url = "http://hl7.org/fhir/StructureDefinition/cqf-expression"
  * valueExpression
    * language  = #text/fhirpath
    * expression = {expression}

RuleSet: sdcQuestionnaireLaunchContext( name, type, description )
* extension[+]
  * url = "http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-launchContext"
  * extension[+]
    * url = "name"
    * valueId = {name}
  * extension[+]
    * url = "type"
    * valueCode = {type}
  * extension[+]
    * url = "description"
    * valueString = {description}

RuleSet: sdcQuestionnaireItemPopulationContext( name, query )
* extension[+]
  * url = "http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-itemPopulationContext"
  * valueExpression
    * name = {name}
    * language = #application/x-fhir-query
    * expression = {query}

RuleSet: sdcAnswerExpression( language, expression )
* extension[+]
  * url = http://hl7.org/fhir/uv/sdc/StructureDefinition/sdc-questionnaire-answerExpression
  * valueExpression
    * language = {language}
    * expression = {expression}

RuleSet: itemControlType( type )
* extension[+]
  * url = "http://hl7.org/fhir/StructureDefinition/questionnaire-itemControl"
  * valueCodeableConcept 
    * coding[+]
      * system = "http://hl7.org/fhir/questionnaire-item-control"
      * code   = {type}

RuleSet: minIntegerValue( minValue )
* extension[+]
  * url = "http://hl7.org/fhir/StructureDefinition/minValue"
  * valueInteger = {minValue}

RuleSet: maxIntegerValue( maxValue )
* extension[+]
  * url = "http://hl7.org/fhir/StructureDefinition/maxValue"
  * valueInteger = {maxValue}

RuleSet: minQuantityValue( minValue, unit )
* extension[+]
  * url = "http://hl7.org/fhir/StructureDefinition/minValue"
  * valueQuantity
    * value = {minValue}
    * unit = {unit}

RuleSet: unitOption( unit )
* extension[+]
  * url = "http://hl7.org/fhir/StructureDefinition/questionnaire-unitOption"
  * valueCoding = {unit}




