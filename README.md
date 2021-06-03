[![](https://images.microbadger.com/badges/image/jbeley/plaso.svg)](https://microbadger.com/images/jbeley/plaso "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/jbeley/plaso.svg)](https://microbadger.com/images/jbeley/plaso "Get your own version badge on microbadger.com")

# docker-plaso
Docker container for plaso supertimlining tool

## Building
The following `make` targets are availible. See Makefile for variable declarations

|target|description
|------|------|
|**build**|build the docker image|
|**build-nocache**|build the docker image without use of docker build caching|
|**cdqr**|run cdqr with "do all the things" plugin set against $EVIDENCE_FILE|
|**cdqr-lin**|run cdqr with Linux specific plugin set against $EVIDENCE_FILE|
|**cdqr-mac**|run cdqr with Mac specific plugin set against $EVIDENCE_FILE|
|**cdqr-win**|run cdqr with Windows specific plugin set against $EVIDENCE_FILE|
|**git-push**|push this repo|
|**hub-build**|schedule bulid on docker hub|
|**log2timeline**|run log2timeline against $EVIDENCE_FILE|
|**pinfo**|run pinfo against WinXP2.plaso|
|**psort-analysis**|run psort with analysis plugins against $EVIDENCE_FILE.plaso|
|**psort-csv**|run pinfo against $EVIDENCE_FILE.plaso|
|**psort**|run pinfo against $EVIDENCE_FILE.plaso|
|**push**|push image to docker hub|
|**shell**|run a shell in the docker container as an unpriviledged user (usefulfor debugging)|
|**shell-root**|run a shell in the docker container as root (useful for debugging)|
|**test**|run all tests|

## Manual Usage after a "make build"
```
docker run --rm -v YOUR_DATA_DIR:/data/ -it accenturecifr/plaso \
   log2timeline.py --status_view linear --parsers YOUR_PARSER_LIST /data/PLASOFILE.pb /data/YOUR_INPUT_DIR/
docker run -v YOUR_DATA_DIR:/data/ -u root -it accenturecifr/plaso psort.py -o json_line -w /data/YOUR_OUTPUT.json /data/PLASOFILE.pb
```


## Plaso's license
see https://github.com/log2timeline/plaso/wiki/Licenses-dependencies

## Credits

* [http://jmkhael.io/makefiles-for-your-dockerfiles/](http://jmkhael.io/makefiles-for-your-dockerfiles/)
* [https://github.com/jessfraz/dockerfiles](https://github.com/jessfraz/dockerfiles)
* [https://github.com/orlikoski/CDQR](https://github.com/orlikoski/CDQR)
* [https://github.com/log2timeline/](https://github.com/log2timeline/)
