#!/usr/bin/env bash

rm ./*.gem
gem build health_bit.gemspec
gem push health_bit-*
