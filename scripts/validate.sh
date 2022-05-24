#!/bin/sh

export FC_SETTINGS=/etc/krakend/config/settings/$ENVIRONMENT/$REGION
cp /etc/krakend/config/settings/shared/* ${FC_SETTINGS}

/usr/bin/krakend check -c /etc/krakend/krakend.json
