# data handling

DB=reca.db
SU=poetry run sqlite-utils

DATA=data/RECA-Covered-Areas.geojson

$(DB):
	$(SU) create-database $@ --init-spatialite --enable-wal

areas: $(DB)
	poetry run geojson-to-sqlite $(DB) $@ $(DATA) --spatialite --spatial-index

run:
	poetry run datasette serve . --load-extension spatialite

src/data/reca.json:
	poetry run datasette . --get /reca/export.geojson \
		--load-extension spatialite > $@

export: src/data/reca.json