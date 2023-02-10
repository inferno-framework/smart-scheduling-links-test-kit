Alias: CPS = http://hl7.org/fhir/contact-point-system

Profile: VaccineLocation
Parent: Location
Id: vaccine-location
* name 1..
* telecom 1..*
* telecom ^slicing.discriminator.type = #pattern
* telecom ^slicing.discriminator.path = "system"
* telecom ^slicing.rules = #open
* telecom contains schedulingTelecom 0..*
* telecom[schedulingTelecom]
* telecom[schedulingTelecom].system from SMARTTelecomSystem (required)
* telecom[schedulingTelecom].system 1..1
* telecom[schedulingTelecom].system ^short = "phone | url"
* telecom[schedulingTelecom].value 1..1
* address 1..1
* address only VaccineAddress
* obeys vaccine-location-1
* identifier ^slicing.discriminator.type = #value
* identifier ^slicing.discriminator.path = "system"
* identifier ^slicing.rules = #open
* identifier ^slicing.description = "Identifier needs at least one VTrckS value"
* identifier contains vTrckS 0..*
* identifier[vTrckS].system = "https://cdc.gov/vaccines/programs/vtrcks"

ValueSet: SMARTTelecomSystem
Id: smart-telecom-system
* include CPS#phone
* include CPS#url

Invariant: vaccine-location-1
Description: "Location should have a phone and URL"
Severity: #warning
Expression: "telecom.where(system = 'phone').exists() and telecom.where(system = 'url').exists()"