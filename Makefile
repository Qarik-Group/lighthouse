.PHONY: logout login start

all: logout login cf

check: login

cf:
	@bin/cf

login:
	@bin/login

logout:
	@bin/logout

