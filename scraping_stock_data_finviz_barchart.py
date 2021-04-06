# -*- coding: utf-8 -*-
"""
Created on Sun Feb 21 16:25:30 2021

@author: Showmic
"""

from datetime import date
import pandas as pd
import urllib.request 
import random 
from collections import OrderedDict
import time
from bs4 import BeautifulSoup

headers_list = [
    # Firefox 77 Mac
     {
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:77.0) Gecko/20100101 Firefox/77.0",
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
        "Accept-Language": "en-US,en;q=0.5",
        "Referer": "https://www.google.com/",
        "DNT": "1",
        "Connection": "keep-alive",
        "Upgrade-Insecure-Requests": "1"
    },
    # Firefox 77 Windows
    {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:77.0) Gecko/20100101 Firefox/77.0",
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
        "Accept-Language": "en-US,en;q=0.5",
        "Accept-Encoding": "utf-8",
        "Referer": "https://www.google.com/",
        "DNT": "1",
        "Connection": "keep-alive",
        "Upgrade-Insecure-Requests": "1"
    },
    # Chrome 83 Mac
    {
        "Connection": "keep-alive",
        "DNT": "1",
        "Upgrade-Insecure-Requests": "1",
        "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.97 Safari/537.36",
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
        "Sec-Fetch-Site": "none",
        "Sec-Fetch-Mode": "navigate",
        "Sec-Fetch-Dest": "document",
        "Referer": "https://www.google.com/",
        "Accept-Encoding": "utf-8",
        "Accept-Language": "en-GB,en-US;q=0.9,en;q=0.8"
    },
    # Chrome 83 Windows 
    {
        "Connection": "keep-alive",
        "Upgrade-Insecure-Requests": "1",
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.97 Safari/537.36",
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9",
        "Sec-Fetch-Site": "same-origin",
        "Sec-Fetch-Mode": "navigate",
        "Sec-Fetch-User": "?1",
        "Sec-Fetch-Dest": "document",
        "Referer": "https://www.google.com/",
        "Accept-Encoding": "utf-8",
        "Accept-Language": "en-US,en;q=0.9"
    }
]
# Create ordered dict from Headers above
ordered_headers_list = []
for headers in headers_list:
    h = OrderedDict()
    for header,value in headers.items():
        h[header]=value
    ordered_headers_list.append(h)



headers = random.choice(headers_list)    
url='https://finviz.com/screener.ashx?v=111&f=fa_epsyoy1_pos,sh_avgvol_o500,sh_price_u10&ft=4&o=price&ar=180'
req = urllib.request.Request(url=url, headers=headers) 


resp = urllib.request.urlopen(req)
respData = resp.read()
html = respData.decode('utf-8')
# print(html)
tables_test = pd.read_html(html)
appended_data=pd.DataFrame(tables_test[16])
header=appended_data.iloc[0]
appended_data=appended_data[1:]
appended_data.columns=header
count=0
for ii in range(23):
    print(ii)
    url='https://finviz.com/screener.ashx?v=111&f=fa_epsyoy1_pos,sh_avgvol_o500,sh_price_u10&ft=4&o=price&ar=180'+'&r='+str(21+count)
    # print(url)
    headers = random.choice(headers_list)
    req = urllib.request.Request(url=url, headers=headers) 
    resp = urllib.request.urlopen(req)
    respData = resp.read()
    html = respData.decode('utf-8')
    tables = pd.read_html(html)
    data=pd.DataFrame(tables[16])
    data=data[1:]
    data.columns=header
    appended_data=appended_data.merge(data,how='outer')
    count=count+20
# print(appended_data)
column_barchart=['Market Capitalization, $K', 'Shares Outstanding, K', 'Annual Sales, $',
       'Annual Net Income, $', 'Last Quarter Sales, $',
       'Last Quarter Net Income, $', '60-Month Beta',
       '% of Insider Shareholders', '% of Institutional Shareholders',
       'Float, K', '% Float']
column_barchart_table1=['1-Year Return', '3-Year Return', '5-Year Return' ,'5-Year Revenue Growth' ,'5-Year Earnings Growth', '5-Year Dividend Growth']
# print(column_barchart)
column_barchart2=['Barchart recommendation deatils']
data_final=pd.DataFrame(columns=column_barchart)
data_barchart2=pd.DataFrame(columns=column_barchart2)
print(len(appended_data['Ticker']))
counter_agent=0
counter=0
for ii in range(len(appended_data['Ticker'])):
    ticker=appended_data.iloc[ii]['Ticker']
    url_barchart='https://www.barchart.com/stocks/quotes/'+str(ticker)+'/profile'
    headers = random.choice(headers_list)
    req = urllib.request.Request(url=url_barchart, headers=headers)
    resp = urllib.request.urlopen(req)
    respData = resp.read()
    html = respData.decode('utf-8')
    # print(html)
    try:
        tables_test = pd.read_html(html)
    except IndexError:
        tables_test[0]=['N/A','N/A','N/A','N/A','N/A','N/A','N/A','N/A','N/A','N/A','N/A']
    # print(tables_test[0])
    print(counter)
    url_barchart2='https://www.barchart.com/stocks/quotes/'+str(ticker)+'/opinion'
    req = urllib.request.Request(url=url_barchart2, headers=headers)
    resp = urllib.request.urlopen(req)
    respData = resp.read()
    html = respData.decode('utf-8')
    soup = BeautifulSoup(html, 'html.parser')
    try:
        results = soup.find(class_='opinion-status')
        text=results.text
    except AttributeError:
        text = 'No Recommendation found'   
    print(ticker)
    # print(results.text)
    # print(results2.text)
    df_test=pd.DataFrame([text])
    df_test=df_test.transpose()
    df_test.columns=column_barchart2
    appended_data_test=pd.DataFrame(tables_test[0])
    appended_data_test=appended_data_test.transpose()
    # header=appended_data_test.iloc[0]
    appended_data_test=appended_data_test[1:]
    appended_data_test.columns=column_barchart
    data_barchart2=data_barchart2.merge(df_test,how='outer')
    data_final=data_final.merge(appended_data_test,how='outer')
    data_final2=pd.concat([data_final,data_barchart2], axis=1)
    counter+=1
    
    # time.sleep(3)
print(data_final2)
result=pd.concat([appended_data,data_final2], axis=1)
today = date.today()
result.to_csv('C:\\your\desired\directory'+str(today)+'.csv')