Profile: VaccineAddress
Parent: Address
Id: vaccine-address
* ^url = "http://fhir-registry.smarthealthit.org/StructureDefinition/vaccine-location-address"
* text 0..0
* text ^definition = "Cannot use text formatted address"
* line 1..*
* line ^definition = "Must have at least one address line"
* city 1..1
* city ^definition = "Must have city"
* state 1..1
* state ^definition = "Must have state"
* postalCode 1..1
* postalCode ^definition = "Must have zip code"
