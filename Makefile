
.PHONY: render
render:
	rm -rf golden
	mkdir -p golden
	up composition render apis/xencryptionkeys/go-composition.yaml examples/go-xencryptionkey.yaml --format=yaml > golden/go-xencryptionkey.yaml
	up composition render apis/xencryptionkeys/go-tmpl-composition.yaml examples/go-tmpl-xencryptionkey.yaml --format=yaml > golden/go-tmpl-xencryptionkey.yaml
	up composition render apis/xencryptionkeys/kcl-composition.yaml examples/kcl-xencryptionkey.yaml --format=yaml > golden/kcl-xencryptionkey.yaml
	make cue


.PHONY: cue
cue:
	up composition render apis/xencryptionkeys/cue-composition.yaml examples/cue-xencryptionkey.yaml > golden/cue-xencryptionkey.yaml

.PHONY: test
test:
	up test run tests/*

.PHONY: test-e2e
test-e2e:
	up test run --e2e tests/*

.PHONY: build
build:
	up project build
