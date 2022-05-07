#!/bin/bash

NUMBER_OF_ACCOUNTS=10

for i in $(seq 0 ${NUMBER_OF_ACCOUNTS})
do
	sudo docker exec -ti proxy ./proxy-cli.sh account new
done

./airdrop.sh
