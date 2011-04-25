DESTDIR=/

all: rel2

rel2:
	bash buildfull.sh

clean:
	bash cleanfull.sh
	rm -rf rel2/

install:
	bash dist.sh "$(DESTDIR)"
