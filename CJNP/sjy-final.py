import math

n = 9 
l = 1410.0
lSquared = l*l

a = 0.0000000

iterNum = 1000

for aIter in range(1, int(l)*iterNum) :
	a = aIter/float(iterNum)
	mInit = (a*l) / math.sqrt(lSquared - a*a)
	mnow = mInit

	i = n
	while i > 2 :
		mnow = (lSquared*mnow + (a*l*math.sqrt(lSquared+mnow*mnow-a*a))) / (lSquared - a*a)
		i -= 1
		
	if mnow > l :
		a = a - 1/float(iterNum)
		print "[fin] a : " + str(a)
		
		mnow = mInit
		print "M" + str(n-1) + " = " + str(mnow)

		i = n
		while i > 2 :
			i -= 1
			mnow = (lSquared*mnow + (a*l*math.sqrt(lSquared+mnow*mnow-a*a))) / (lSquared - a*a)
			print "M" + str(i-1) + " = " + str(mnow)
		break
