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
                resource: createBmiObservation(),
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