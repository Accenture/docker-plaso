NS ?= accenturecifr
VERSION ?= latest
IMAGE_NAME ?= plaso
CONTAINER_NAME ?= plaso
CONTAINER_INSTANCE ?= default

INPUTDIR="/tmp/"
OUTPUTDIR=/tmp
EVIDENCE_FILE=LM_Remote_Service02_7045.evtx
VOLUMES=-v ${INPUTDIR}:/data:cached -v ${OUTPUTDIR}:/output:cached
ENV=
PORTS=
HUB_URL=
.PHONY: build push shell run start stop rm release

# if make_env exists, include it
ifneq ("$(wildcard make_env)", "")
        include make_env
endif

build: Dockerfile
	docker build -t ${NS}/${IMAGE_NAME}:${VERSION} -f Dockerfile .

build-nocache: Dockerfile
	docker build --no-cache -t ${NS}/${IMAGE_NAME}:${VERSION} -f Dockerfile .

hub-build: Dockerfile
	curl -H "Content-Type: application/json" --data '{"build": true}' -X POST ${HUB_URL}

git-push:
	git commit && \
	git push

push:
	docker push ${NS}/${IMAGE_NAME}:${VERSION}

shell:
	docker run --rm --name ${CONTAINER_NAME}-${CONTAINER_INSTANCE} -i -t ${PORTS} ${VOLUMES} ${ENV} ${NS}/${IMAGE_NAME}:${VERSION} /bin/bash

shell-root:
	docker run -u root --rm --name ${CONTAINER_NAME}-${CONTAINER_INSTANCE} -i -t ${PORTS} ${VOLUMES} ${ENV} ${NS}/${IMAGE_NAME}:${VERSION} /bin/bash

run:
	docker run --rm --name ${CONTAINER_NAME}-${CONTAINER_INSTANCE} ${PORTS} ${VOLUMES} ${ENV} ${NS}/${IMAGE_NAME}:${VERSION}

start:
	docker run -d --name ${CONTAINER_NAME}-${CONTAINER_INSTANCE} ${PORTS} ${VOLUMES} ${ENV} ${NS}/${IMAGE_NAME}:${VERSION}

stop:
	docker stop ${CONTAINER_NAME}-${CONTAINER_INSTANCE}

rm:
	docker rm ${CONTAINER_NAME}-${CONTAINER_INSTANCE}

release: build
	make push -e VERSION=${VERSION}

test: cdqr psort-analysis psort psort-csv pinfo

log2timeline:
	mkdir -p ${OUTPUTDIR}/log2timeline && \
	docker run --rm ${VOLUMES} ${NS}/${IMAGE_NAME} log2timeline.py \
		--artifact_definitions /usr/share/artifacts \
		--data /usr/share/plaso \
		--workers=$(shell nproc) \
		--partitions all \
		--vss_stores all \
		--hashers md5 \
		--logfile /output/log2timeline/${EVIDENCE_FILE}.plaso.log \
		-q \
		/output/log2timeline/${EVIDENCE_FILE}.plaso /data/${EVIDENCE_FILE}

psort-analysis:
	mkdir -p ${OUTPUTDIR}/log2timeline && \
	docker run --rm ${VOLUMES} ${NS}/${IMAGE_NAME} psort.py \
		-o null \
		--data /usr/share/plaso \
		--tagging-file /usr/share/plaso/tag_windows.txt \
		--analysis tagging,sessionize,windows_services \
		/output/log2timeline/${EVIDENCE_FILE}.plaso

psort:
	rm -f ${OUTPUTDIR}/log2timeline/${EVIDENCE_FILE}.json
	mkdir -p ${OUTPUTDIR}/log2timeline && \
	docker run --rm ${VOLUMES} ${NS}/${IMAGE_NAME} psort.py \
		-o json_line \
		-w /output/log2timeline/${EVIDENCE_FILE}.json \
		--logfile /output/log2timeline/${EVIDENCE_FILE}.psort.log \
		-q \
		--status_view none \
		/output/log2timeline/${EVIDENCE_FILE}.plaso

psort-csv:
	mkdir -p ${OUTPUTDIR}/log2timeline && \
	docker run --rm ${VOLUMES} ${NS}/${IMAGE_NAME} psort.py \
		-o l2tcsv \
		-w /output/log2timeline/${EVIDENCE_FILE}.csv \
		/output/log2timeline/${EVIDENCE_FILE}.plaso \
		--logfile /output/log2timeline/${EVIDENCE_FILE}.psort-csv.log \
		--status_view none \
		-q

pinfo:
	mkdir -p ${OUTPUTDIR}/log2timeline && \
	docker run --rm ${VOLUMES} ${NS}/${IMAGE_NAME} pinfo.py \
		--output_format json \
		-w /output/log2timeline/${EVIDENCE_FILE}-pinfo.json \
		/output/log2timeline/${EVIDENCE_FILE}.plaso

cdqr:
	mkdir -p ${OUTPUTDIR}/log2timeline && \
	rm -f ${OUTPUTDIR}/log2timeline/${EVIDENCE_FILE}.json && \
	docker run --rm -it ${VOLUMES} ${NS}/${IMAGE_NAME} cdqr.py \
		--max_cpu -y \
		-p datt \
		--export /data/${EVIDENCE_FILE} \
		/output/log2timeline/

cdqr-lin:
	mkdir -p ${OUTPUTDIR}/log2timeline && \
	docker run --rm -it ${VOLUMES} ${NS}/${IMAGE_NAME} cdqr.py \
		--max_cpu \
		-p lin -y \
		--export /data/${EVIDENCE_FILE} \
		/output/log2timeline/

cdqr-win:
	mkdir -p ${OUTPUTDIR}/log2timeline && \
	docker run --rm -it ${VOLUMES} ${NS}/${IMAGE_NAME} cdqr.py \
		--max_cpu \
		-p win -y \
		--export /data/${EVIDENCE_FILE} \
		/output/log2timeline/

cdqr-mac:
	mkdir -p ${OUTPUTDIR}/log2timeline && \
	docker run --rm -it ${VOLUMES} ${NS}/${IMAGE_NAME} cdqr.py \
		--max_cpu \
		-p mac -y \
		--export /data/${EVIDENCE_FILE} \
		/output/log2timeline/

default: build
