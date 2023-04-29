DB=gov_br
BUILD=sql/build.sql
CSV='/user_data/cigarros.csv'
MASTER=sql/import.sql
NORMALIZE=sql/normalize.sql

all: normalize
	sh scripts/10_psql.sh <  $(BUILD)

master:
	@cat $(MASTER) >> $(BUILD)

import: master
	@echo "COPY import.cigarettes FROM $(CSV) WITH DELIMITER ';' HEADER CSV;" >> $(BUILD)

normalize: import
	@cat $(NORMALIZE) >> $(BUILD)

clean:
	@rm -rf $(BUILD)
