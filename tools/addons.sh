#!/bin/bash

apt-get update && apt-get install -y tmux vim cowsay

cowsay "Howdy Azure Bootcamp!" > /tmp/cowsay.txt
