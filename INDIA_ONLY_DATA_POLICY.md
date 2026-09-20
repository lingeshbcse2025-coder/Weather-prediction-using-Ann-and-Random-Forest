# India-Only Data Policy

Only Indian weather observations enter the active pipeline: training,
evaluation, artifacts, and serving.

Forbidden in the active pipeline: Australia, weatherAUS, Rain in Australia,
mixed-country datasets, and any model artifact trained on them.

## Enforcement (D-014)

This is enforced at the **data and artifact** layer, not by scanning
documentation text:

- `weatherai/data/validate.py` rejects any row whose location is not one of
  the five configured Indian cities, whose coordinates fall outside an India
  bounding box, or whose location string contains a forbidden-region token.
  `tests/data/test_validation.py::test_india_only_locations` and
  `test_no_forbidden_region_tokens_in_locations` cover this.
- `weatherai/ml/registry.py::load_bundle` refuses to load any artifact whose
  `metadata.json["dataset"]` does not say `"country": "India"` or contains an
  `australia`/`weatheraus` token anywhere in its dataset metadata.
- `tests/data/test_validation.py::test_kaggle_source_is_rejected` and
  `tests/ml/test_pipeline.py::test_no_forbidden_source_in_any_model_hyperparameter_dump`
  assert both of the above stay true.

An earlier version of this policy was enforced by `scripts/check_india_only.py`,
which grepped every repository file for the strings "australia" / "weatheraus".
That script failed on the untouched repository (23 false positives — it
flagged this very document, the README, and its own blocklist) because the
policy's subject is data and artifacts, not prose. It has been removed; see
`docs/DECISIONS.md` D-014. Documentation, including this file, may name the
excluded dataset in order to say it is excluded.

The rejected Kaggle source and the evidence for rejecting it are kept at
`data/raw/kaggle_rain_forecasting/` for the record; see `docs/DECISIONS.md`
D-010.
