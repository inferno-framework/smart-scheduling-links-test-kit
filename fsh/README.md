# SMART Scheduling Links (FSH Edition)
This folder contains an effort to represent the FHIR [SMART Scheduling
Links](https://github.com/smart-on-fhir/smart-scheduling-links/) specification
in [FHIR Shorthand](http://hl7.org/fhir/uv/shorthand/) to support automated
conformance testing. Suggestions and updates are welcome to better match the
intent of the SMART Scheduling Links Spec.

## Requirements
Generating the IG package requires
[sushi](https://fshschool.org/docs/sushi/installation/) and
[jekyll](https://jekyllrb.com/docs/installation/).

## Generating the IG Package
Once these are installed, run:

* `sushi`
* `_updatePublisher.sh` (mac/linux) or `_updatePublisher.bat` (windows)
* `_genonce.sh` (mac/linux) or `_genonce.bat` (windows)
* `cp output/package.tgz ../lib/smart_scheduling_links_test_kit/igs/`
   
## License
Copyright 2023 The MITRE Corporation

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
