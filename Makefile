.PHONY: logout login start

login:
	bin/login

start:
	bin/start

logout:
	bin/logout

test: login start