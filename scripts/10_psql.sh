#!/usr/bin/env bash
if [ -t 0 ]; then
	# interactive
	exec docker compose exec --user postgres postgres psql $@
else
	# non-interactive
	exec docker compose exec --user postgres -T postgres psql $@
fi
