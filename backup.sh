#!/bin/sh

mysqldump -u root -pqwerty --all-databases > db.dump
gzip -f db.dump
git commit -m "database" db.dump.gz
git push origin master
