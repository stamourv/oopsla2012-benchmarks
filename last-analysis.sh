#!/bin/bash

cat dumps/`ls dumps/ | grep .analysis | sort | tail -1`
