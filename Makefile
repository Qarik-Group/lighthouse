.PHONY: bosh bosh-login bosh-logout cf cf-logout cf-login

all: cf-logout cf-login cf

bosh:
	@bin/bosh/run

bosh-login:
	@bin/bosh/login
	@. lib/bosh/env.sh

bosh-logout:
	@bin/bosh/logout

check: cf-login

cf:
	@bin/cf/run

cf-login:
	@bin/cf/login

cf-logout:
	@bin/cf/logout


