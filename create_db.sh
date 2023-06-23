#!/usr/bin/env bash

cat <<EOF | sudo -u postgres -i psql
create database ddtb_debug;
grant all privileges on database ddtb_debug to www;
\c ddtb_debug;
grant usage, create on schema public to www;
EOF

