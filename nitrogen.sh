#!/usr/bin/env python3

#Usage: 
#1. Run "sudo raspi-config" to enable I2C interface
#2. Install: "sudo pip3 install adafruit-circuitpython-ads1x15 
#3. Run the program

import time
import board
import busio
import adafruit_ads1x15.ads1015 as ADS
from adafruit_ads1x15.analog_in import AnalogIn



import requests
from requests.packages.urllib3.exceptions import InsecureRequestWarning
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)

DATABASE='https://dbod-ids-db.cern.ch:8080/write?db=ids'
LOGIN='admin'
PASSWORD='hello_is_it_rates_youre_looking_for'
TABLE_NAME='nitrogen'




# Create the I2C bus
i2c = busio.I2C(board.SCL, board.SDA)

# Create the ADC object using the I2C bus
ads = ADS.ADS1015(i2c)

# Create single-ended input on channel 1
chan = AnalogIn(ads, ADS.P1)

# Create differential input between channel 0 and 1
#chan = AnalogIn(ads, ADS.P0, ADS.P1)

print("{:>5}\t{:>5}".format('raw', 'v'))

while True:
	print("{:>5}\t{:>5.3f}".format(chan.value, chan.voltage))


# Push voltage value to influxdb for grafana

	dataString = TABLE_NAME + ' voltage=' + ('%.2f' % chan.voltage)
	print(dataString) 

	try:
		r = requests.post(DATABASE, auth=(LOGIN, PASSWORD), data=dataString, verify=False, timeout=10)
		print(r)
#		print('204 = everything ok')
	except InsecureRequestWarning:
		pass
		print('Influxdb Error')
	except requests.exceptions.HTTPError as errh:
		print ("Http Error:",errh)
	except requests.exceptions.ConnectionError as errc:
		print ("Error Connecting:",errc)
	except requests.exceptions.Timeout as errt:
		print ("Timeout Error:",errt)
	except requests.exceptions.RequestException as err:
		print ("OOps: Something Else",err)


	time.sleep(5)
    
