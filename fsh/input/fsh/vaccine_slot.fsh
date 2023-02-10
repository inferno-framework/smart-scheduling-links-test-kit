Alias: SSTAT = http://hl7.org/fhir/slotstatus
Alias: $BookingDeepLink = booking-deep-link
Alias: $BookingPhone = booking-phone
Alias: $BookingCapacity = slot-capacity

Profile: VaccineSlot
Parent: Slot
Id: vaccine-slot
* status from VaccineSlotStatus (required)
* status ^short = "free | busy"
* extension contains
    $BookingDeepLink named booking-link 0..1 MS and
    $BookingPhone named booking-phone 0..1 MS and
    $BookingCapacity named capacity 0..1 MS

ValueSet: VaccineSlotStatus
Id: vaccine-slot-status
* include SSTAT#free
* include SSTAT#busy

Extension: BookingDeepLink
Id: booking-deep-link
* value[x] 1..1
* value[x] only url

Extension: BookingPhone
Id: booking-phone
* value[x] 1..1
* value[x] only string

Extension: BookingCapacity
Id: slot-capacity
* value[x] 1..1
* value[x] only integer
