import boto3
from bs4 import BeautifulSoup
from urllib.request import Request, urlopen
import re
from linebot.v3.messaging import (
    Configuration,
    ApiClient,
    MessagingApi,
    ReplyMessageRequest,
    TextMessage,
    PushMessageRequest,
    ApiException
)
from linebot.v3 import (
    WebhookHandler
)
import json
import os
dynamodb = boto3.resource('dynamodb')
result = {}
hdr = {
    'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.64 Safari/537.11',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    'Accept-Charset': 'ISO-8859-1,utf-8;q=0.7,*;q=0.3',
    'Accept-Encoding': 'none',
    'Accept-Language': 'ja-JP,en-US;q=0.7,en-GB;q=0.3',
    'Connection': 'keep-alive'}
#
#
configuration = Configuration(access_token=os.environ['LINE_CHANNEL_ACCESS_TOKEN'])
line_id = os.environ['YOUR_USER_ID']
# handler = WebhookHandler(os.environ['LINE_CHANNEL_SECRET'])
input = os.environ['PASTEBIN_CSV_URL'] # sample: https://pastebin.com/raw/fiGthbuY
scraping_table = dynamodb.Table(os.environ['DYNAMODB_TABLE_NAME'])

def lambda_handler(event, context):

    response = urlopen(Request(input,headers=hdr))
    soup = BeautifulSoup(response,"lxml")
    dump = soup.find("p").text
    for l in dump.splitlines():
        column = l.split(",")
        alertAmznTrackingPrice(column[0],int(column[1]))

    if not result:
        return {
            'statusCode': 200,
            'body': json.dumps(result)
        }

    message_dict = {
        'to': line_id,
        'messages': [
            {
                'type': 'text',
                'text': json.dumps(result)
            },
        ]
    }

    with ApiClient(configuration) as api_client:
        # Create an instance of the API class
        api_instance = MessagingApi(api_client)
        push_message_request = PushMessageRequest.from_dict(message_dict)

        try:
            push_message_result = api_instance.push_message_with_http_info(push_message_request, _return_http_data_only=False)
            print(f'The response of MessagingApi->push_message status code => {push_message_result.status_code}')
        except ApiException as e:
            print('Exception when calling MessagingApi->push_message: %s\n' % e)

    return {
        'statusCode': 200,
        'body': json.dumps(result)
    }

def amznTrackingPrice(amznURL):
    # https://www.scrapingdog.com/blog/scrape-amzn/
    
    amznPage = urlopen(Request(amznURL,headers=hdr))
    soup = BeautifulSoup(amznPage,"lxml")
    # print(soup)
    
    try:
        # Outer Tag Object
        title = soup.find("span", attrs={"id":'productTitle'})
        # Inner NavigableString Object
        title_value = title.string
        # Title as a string value
        title_string = title_value.strip()
        # print(title_string)
        
        try:
            exists = soup.find("span",{"class":"a-size-medium a-color-success"})
            if exists:
                if '現在在庫切れです。' in exists.text:
                    return (999999,title_string)

            price = soup.find("span",{"class":"a-price"}).find("span").text
            price = re.sub(r"\D", "", price)
            #
            try:
                coupon = soup.find("label",{"style":"display:inline; font-weight: normal; cursor: pointer;"}).text
                coupon = re.sub(r"\D", "", coupon)
                result = int(price)-int(coupon)
                return (result,title_string)
                # %クーポンには対応してない(要サンプル)
            except: # クーポンなし
                result = int(price)
                return (result,title_string)
        except: # 価格取得不可？
            return (999999,title_string)
    except: # ページなし
        return (999999,"missing")
    
def alertAmznTrackingPrice(amznURL, target):
    price,title = amznTrackingPrice(amznURL)
    old_price = 999999

    response = scraping_table.get_item(
            Key={
                'URL': amznURL
            }
        )
    
    if 'Item' in response:
        item = response['Item']
        old_price = item.get('Price')

    response = scraping_table.put_item(
        Item={
            'URL': amznURL,
            'Price': price,
            'Title': title
        }
    )
    
    if price > old_price:
        return

    if price <= target:
        result[amznURL] = price

