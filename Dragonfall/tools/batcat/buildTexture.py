#coding=utf-8
#DannyHe
from basic import *
from batcat import *

NATIVEPLATFORMS=("iOS","Player","Android","WP")

def getNativePlatform(args = ""):
	result = args
	message = "Platform :\n"
	for index in range(len(NATIVEPLATFORMS)):
		message = message + str(index + 1) + "." + NATIVEPLATFORMS[index] + "\n"
	while not result in NATIVEPLATFORMS:
		opt = raw_input(message)
		if opt.isdigit():
			index = int(opt) - 1
			if index in range(len(NATIVEPLATFORMS)):
				result = NATIVEPLATFORMS[index]
	return result

Platform = ""