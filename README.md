# Inferno SMART Scheduling Links Test Kit

This is a collection of tests for [SMART Scheduling
Links](https://github.com/smart-on-fhir/smart-scheduling-links).

## Instructions
To run these tests using [Docker](https://www.docker.com/):

- Clone this repo.
- Run `setup.sh` in this repo.
- Run `run.sh` in this repo.
- Navigate to `http://localhost`. The SMART test suite will be available.

For more information on running/developing tests in Inferno, see [Inferno's
documentation](https://inferno-framework.github.io/inferno-core/getting-started.html).

## Updating This Test Kit
This test kit depends on HL7® FHIR® profiles generated from FHIR Shorthand in
the `fsh` directory. If any changes are made to the structure of the resources
in the spec, the files in `fsh/input/fsh` will need to be updated to reflect
those changes. The readme in the `fsh` directory contains instructions for
generating the profiles and using them in the test kit.

Any other changes made to the spec will require updating the files in `lib` to
reflect the changes.

## License

Licensed under the Apache License, Version 2.0 (the "License"); you may not use
this file except in compliance with the License. You may obtain a copy of the
License at
```
http://www.apache.org/licenses/LICENSE-2.0
```
Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied. See the License for the
specific language governing permissions and limitations under the License.

## Trademark Notice

HL7, FHIR and the FHIR [FLAME DESIGN] are the registered trademarks of Health
Level Seven International and their use does not constitute endorsement by HL7.
