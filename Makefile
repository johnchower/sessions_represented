QUERIES = $(wildcard queries/*)
auth_file := ~/.auth
.DEFAULT_GOAL := output.zip

output.zip: data.zip R/calculate.r
	mkdir -p output; \
	echo "Output directory created"; \
	unzip data.zip; \
	echo "Data directory unzipped"; \
	Rscript ./R/calculate.r ; \
	echo "calculation complete"; \
	rm -rf data; \
	echo "data directory removed"; \
	zip -r output.zip output; \
	echo "output directory zipped"; \
	rm -rf output

data.zip: queries.zip R/load_queries.r
	mkdir queries_unzipped; \
	unzip queries.zip -d queries_unzipped; \
	mv queries_unzipped/queries/* queries_unzipped; \
	rm -rf queries_unzipped/queries; \
	mkdir data; \
	Rscript ./R/load_queries.r --query_directory queries_unzipped --csv_directory data --auth_file_location $(auth_file); \
	ls data; \
	zip -r data.zip data; \
	rm -rf data; \
	rm -rf queries_unzipped

queries.zip: $(QUERIES)
	zip -r queries.zip queries

mkfileViz.png: makefile2dot.py Makefile
	python makefile2dot.py <Makefile |dot -Tpng > mkfileViz.png

clean: 
	rm queries.zip data.zip; \
	rm -rf output; \
	rm -rf data; \

.PHONY: clean
