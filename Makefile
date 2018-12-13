.PHONY: bosh bosh-login bosh-logout check-vault cf cf-logout cf-login

all: cf-logout cf-login cf

bosh:
	@bin/bosh/run

bosh-login:
	@bin/bosh/login

bosh-logout:
	@bin/bosh/logout

check: bin/lh check

check-all: check-vault bosh-login cf-login

check-vault:
	@bin/vault/check

cf: 
	@bin/cf/run

cf-login:
	@bin/cf/login

cf-logout:
	@bin/cf/logout

