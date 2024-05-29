mkdir python
pip3 install beautifulsoup4 -t ./python
pip3 install requests==2.31.0 -t ./python
pip3 install lxml -t ./python
pip3 install line-bot-sdk -t ./python # include requests
zip -r beautifulsoup.zip python
rm -r python
