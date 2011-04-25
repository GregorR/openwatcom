DESTDIR=/

all: rel2

rel2:
	bash buildfull.sh

clean:
	bash cleanfull.sh

install:
	bash dist.sh "$(DESTDIR)"
