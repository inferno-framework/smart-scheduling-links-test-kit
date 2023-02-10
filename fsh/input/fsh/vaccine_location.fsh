Alias: CPS = http://hl7.org/fhir/contact-point-system

Profile: VaccineLocation
Parent: Location
Id: vaccine-location
* name 1..
* telecom 1..*
* telecom.system 1..
* telecom.system from SMARTTelecomSystem (required)
* telecom.value 1..
* address 1..1
* address only VaccineAddress
* identifier.system 1..1
* identifier.value 1..1
* obeys vaccine-location-1
* obeys vaccine-location-2
* obeys vaccine-location-3
* identifier ^slicing.discriminator.type = #value
* identifier ^slicing.discriminator.path = "system"
* identifier ^slicing.rules = #open
* identifier ^slicing.description = "Identifier needs at least one VTrckS value"
* identifier contains vTrckS 1..* MS
* identifier[vTrckS].system = "https://cdc.gov/vaccines/programs/vtrcks"

ValueSet: SMARTTelecomSystem
Id: smart-telecom-system
* include CPS#phone
* include CPS#url

Invariant: vaccine-location-1
Description: "Location should have a phone and URL"
Severity: #warning
Expression: "telecom.where(system = 'phone').exists() and telecom.where(system = 'url').exists()"

Invariant: vaccine-location-2
Description: "If a telecom claims to be a phone number, it should only have phone-like characters"
Severity: #error
Expression: "telecom.where(system = 'phone' and value.contains('@')).empty()"

Invariant: vaccine-location-3
Description: "If a telecom claims to be a URL, it should only have url-like characters"
Severity: #error
Expression: "telecom.where(system = 'url').exists() implies telecom.where(system = 'url' and value.contains(' ')).empty()"