# ReNEW-LDES-Demonstrator

## LDES Demonstrator for ReNEW

LDES demonstration for the ReNEW project.

## Data Source
The data sources are the following environment sensors:
- **51°06'12.5"N 3°43'37.3"E, Gent**: A water level and temperature sensor, also provides info of `battery_voltage`.
- **51°12'28.9"N 3°48'19.3"E, Marina Zelzate**: A water quality sensors, measuring:
    - conductivity
    - diss_oxygen
    - turbidity
    - chlorophyll
    - depth
    - temperature

The data is exposed through an API endpoint, as demonstrated in the [Postman collection](postman).

## Mapping to RDF
Each individual sensor reading (e.g., from [be61a56a-038b-44dc-86f2-8c319739efc8](https://renew.iccs.gr/projects/41837b47-5e2f-4e25-973b-ae74980b7ea8/devices/be61a56a-038b-44dc-86f2-8c319739efc8)) at **51°12'28.9"N 3°48'19.3"E, Marina Zelzate** follows this format:

```json
{
  "time": "2025-03-04T12:00:00Z",
  "float_value": 1.27,
  "string_value": null,
  "location": null,
  "created_on": "2025-03-04T12:16:15.882356Z",
  "ObservedPropertyType": {
    "observed_property_type_name": "depth",
    "unit": "m",
    "properties": {},
    "value_type": "float"
  }
}
```

The RDF mapping should reuse existing ontologies and vocabularies as much as possible, the mapping follows examples:
- [OSLO-mapping: emissie_water.ttl](https://github.com/Informatievlaanderen/OSLO-mapping/blob/fce5254af9904270e55eaabfe62450da1dac00c2/docs/_water/IMJV/emissie_water.ttl#L15)
- [OSLO-mapping: debiet_observaties_water.ttl](https://github.com/Informatievlaanderen/OSLO-mapping/blob/fce5254af9904270e55eaabfe62450da1dac00c2/docs/_water/IMJV/debiet_observaties_water.ttl)

The model is built on RDF* using blank nodes. This is supported by the [VSDS LDES Server](https://informatievlaanderen.github.io/VSDS-LDESServer4J/). Alternatively, you can map the data in a named graph to set clear boundaries for each member, but this feature is not yet supported by the LDES server used in this project.

### RDF Mapping
> **Note:** The `time` field represents the actual measurement timestamp, while `created_on` indicates when the measurement became available via the API. The `created_on` timestamp is disregarded in the RDF mapping.

```turtle
# Nested structure using RDF* with blank nodes
@prefix devices: <https://renew.iccs.gr/projects/41837b47-5e2f-4e25-973b-ae74980b7ea8/devices/> .
@prefix prov: <http://www.w3.org/ns/prov#> .
@prefix qudt: <http://qudt.org/schema/qudt/> .
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .
@prefix schema: <https://schema.org/> .
@prefix si-unit: <https://si-digital-framework.org/SI/units/> .
@prefix sosa: <http://www.w3.org/ns/sosa/> .
@prefix terms: <http://purl.org/dc/terms/> .
@prefix units: <https://si-digital-framework.org/SI/units/> .
@prefix waterkwaliteit: <https://data.vlaanderen.be/ns/waterkwaliteit#> .
@prefix xsd: <http://www.w3.org/2001/XMLSchema#> .

devices:be61a56a-038b-44dc-86f2-8c319739efc8/{current-time}  # The subject is device ID + timestamp when data arrives in the pipeline
    a sosa:Observation ;
    terms:isVersionOf devices:be61a56a-038b-44dc-86f2-8c319739efc8 ;  # Device ID (accessible via the given URL)
    qudt:numericValue "1.27E0"^^xsd:float ;
    qudt:value rdf:nil ;  # Use rdf:nil for an undefined or empty value
    prov:generatedAtTime "2025-03-05T14:10:18.759560Z"^^xsd:dateTime ;  # Maps the actual measurement timestamp as generatedAtTime, discarding created_on
    sosa:madeBySensor devices:be61a56a-038b-44dc-86f2-8c319739efc8 ;  # Device ID (accessible via the given URL)
    sosa:observedProperty [
        rdfs:label "chlorophyll" ;
        qudt:hasQuantityKind "float" ;
        qudt:siExactMatch () ;
        schema:additionalProperty []
    ] ;
    waterkwaliteit:locatie "51°12'28.9\"N 3°48'19.3\"E" .
```
### Run

```bash
bash run.sh
```
Follow the instructions to launch the setup. The script initializes 4 Docker containers:

- **ReNEW_ldes-server**: This is the LDES server, configured with `configs/ldes-server/renew-observations` files using the bash script. The project is [VSDS-LDESServer4J](https://github.com/Informatievlaanderen/VSDS-LDESServer4J).
- **ldes-postgres**: Persistent storage for the LDES server.
- **pyroscope**: A tool to monitor and visualize the LDES server’s performance.
- **ReNEW_ldes-orchestrator**: This component processes the pipeline to map the original JSON to RDF* as described earlier. The project is [VSDS-Linked-Data-Interactions](https://github.com/Informatievlaanderen/VSDS-Linked-Data-Interactions).

The LDES stream for `sosa:Observation` can be accessed at [http://localhost:8088/renew-observations](http://localhost:8088/renew-observations).  
For a time-fragmented view with "day" granularity based on `prov:generatedAtTime`, visit [http://localhost:8088/renew-observations/by-time](http://localhost:8088/renew-observations/by-time).
