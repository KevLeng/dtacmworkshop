export CARTS_IP=$1
#export CARTS_URL="http:\/\/"$CARTS_IP":8080\/cart"

sed -i "s/CARTS_URL_PLACEHOLDER/$CARTS_IP/g" carts_load1.jmx
sed -i "s/CARTS_URL_PLACEHOLDER/$CARTS_IP/g" carts_load2.jmx