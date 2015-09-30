#-*- coding: cp949 -*-
import urllib2
from bs4 import BeautifulSoup
opener = urllib2.build_opener()
opener.addheaders = [('User-agent', 'Mozilla/5.0')]
opener.addheaders = [('X-UA-Compatible', 'resActiveX=true')]
opener.addheaders = [('Postman-Token', '61220d61-6067-99f0-dfa5-613f4099b27f')]
html = opener.open('http://play.afreeca.com/bokyem123/150188770')
soup = BeautifulSoup(html, "html5lib")
#comments = soup.find_all(class_="user_m")
comments = soup.find_all('dl')
for comment in comments:
	print comment
	print 'user:{0:10s} comment:{1:20s}\n'.format(comment['href'].encode('utf-8'), comment['em'].encode('utf-8'))
