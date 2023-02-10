Alias: $VaccineProduct = vaccine-product
Alias: $VaccineDoseNumber = vaccine-dose

Profile: VaccineSchedule
Parent: Schedule
Id: vaccine-schedule
* actor 1..1
* actor only Reference(Location)
* serviceType 1..
* serviceType ^slicing.discriminator.type = #profile
* serviceType ^slicing.discriminator.path = "$this"
* serviceType ^slicing.rules = #open
* serviceType ^slicing.description = "Slice based on whether the CodeableConcept has 'C19 Immunization Nature'"
* serviceType contains c19Service 1..1
* serviceType[c19Service] only C19ServiceCodeableConcept
* extension contains
    $VaccineProduct named vaccineProduct 0..* and
    $VaccineDoseNumber named vaccineDoseNumber 0..*
* obeys vaccine-schedule-1

Extension: VaccineProduct
Id: vaccine-product
* value[x] 1..1
* value[x] only Coding
* valueCoding.system = "http://hl7.org/fhir/sid/cvx"
* valueCoding.system 1..1
* valueCoding.code 1..1
* valueCoding.display 1..1

Extension: VaccineDoseNumber
Id: vaccine-dose
* value[x] 1..1
* value[x] only integer

Profile: C19ServiceCodeableConcept
Parent: CodeableConcept
Id: c19-service-codeable-concept
* coding ^slicing.discriminator.type = #pattern
* coding ^slicing.discriminator.path = "$this"
* coding ^slicing.rules = #open
* coding ^slicing.description = "Slice based on Coding"
* coding contains 
    immunizationAppointment 1..1 and
    c19ImmunizationAppointment 1..1
* coding[immunizationAppointment] ^patternCoding =  http://terminology.hl7.org/CodeSystem/service-type#57
* coding[c19ImmunizationAppointment] ^patternCoding = http://fhir-registry.smarthealthit.org/CodeSystem/service-type#covid19-immunization

Invariant: vaccine-schedule-1
Description: "Vaccine Product extension SHOULD NOT repeat; providers SHOULD represent each available vaccine product on a separate schedule to facilitate directed booking."
Severity: #warning
Expression: "extension.where(url.contains('vaccine-product')).count() < 2"