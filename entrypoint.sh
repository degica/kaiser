#!/bin/sh

COMMAND="kaiser $@" # Group up our command so we don't lose params
cd "$CONTEXT_DIR"   # Move to the context directory
sh -c "$COMMAND"    # Execute Kaiser
