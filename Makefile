.PHONY: logout login

install:
	bin/install

login:
	bin/login

setup: install login start

start:
	bin/start

logout:
	bin/logout