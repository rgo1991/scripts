#python3

import sys
import requests
from pynotifier import Notification
import bs4
from pathlib import Path
import os
import shelve
import time

# while True:
#
#     def getHTML():
#         res = requests.get('https://www.krepsinis.net')
#         if res.raise_for_status() is not None:
#             print('Download failed')
#         bs4object = bs4.BeautifulSoup(res.text, 'html.parser')
#         elems = bs4object.select('#deskmainPriority > div > div:nth-child(1) > div.title > a.a-text')
#         return elems
#
#
#     def checkandnotify(elems):
#         file = shelve.open('file_previous')
#         if 'previous' not in file.keys():
#             file['previous'] = elems[0].getText()
#             file.close()
#             sys.exit()
#         else:
#             file['current'] = elems[0].getText()
#         if file['previous'] != file['current']:
#             Notification(
#                 title='New Front Page Article',
#                 description=file['current'],
#                 duration=100,
#                 urgency='normal'
#             ).send()
#         del file['previous']
#         file.close()
#
#     checkandnotify(getHTML())
#     time.sleep(10)


last_version = None
while True:
    res = requests.get('https://www.krepsinis.net')
    if res.raise_for_status() is not None:
        print('Download failed')
    bs4object = bs4.BeautifulSoup(res.text, 'html.parser')
    elems = bs4object.select('#deskmainPriority > div > div:nth-child(1) > div.title > a.a-text')
    if elems[0].getText() != last_version:
        last_version = elems[0].getText()
        Notification(
                        title='New Front Page Article',
                        description=elems[0].getText(),
                        duration=10,
                        urgency='normal'
                    ).send()
    time.sleep(100)

