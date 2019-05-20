import os
import socket
import sys
import unicodedata
from argparse import ArgumentParser

from twython import TwythonStreamer


class TwitterStreamer(TwythonStreamer):
    tweets = []
    number_of_batches = 1

    def __init__(self, tcp_connection, *args, **kwargs):
        self.tcp_connection = tcp_connection
        super(TwitterStreamer, self).__init__(*args, **kwargs)

    def on_success(self, data):
        try:
            self.send_tweets_to_spark(data)
        except KeyError as err:
            print("Error while parsing tweet: ", err)
        except:
            print("Unexpected error: ", sys.exc_info()[0])
            raise

    def on_error(self, status_code, data):
        print(status_code, data)
        self.disconnect()

    def send_tweets_to_spark(self, tweet):
        self.tweets.append(self.get_tweet_text(tweet))
        if len(self.tweets) == 100:
            data = "\n".join(map(str, self.tweets))
            self.tcp_connection.send(data.encode(encoding='utf-8'))
            print("Tweets sent to spark: ", self.number_of_batches * 100)
            self.number_of_batches += 1
            self.tweets = []

    @staticmethod
    def get_tweet_text(tweet):
        if not tweet["truncated"]:
            text = map(lambda t: t['text'], tweet)
        else:
            text = map(lambda t: t["extended_tweet"]["full_text"], tweet)
        # lang = map(lambda t: t['lang'], tweet)
        # country = map(lambda t: t['place']['country'] if t['place'] is not None else None, tweet)
        clean_text = unicodedata.normalize(u'NFKD', text).encode('ascii', 'ignore').decode('utf8').replace("\n", " ")
        print(f"""{tweet["id"]} : {clean_text}""")
        return clean_text


def start_socket_server():
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.bind((os.getenv('TCP_IP'), int(os.getenv('TCP_PORT'))))
    s.listen(50)
    print('Waiting for TCP connection...')
    tcp_connection, addr = s.accept()
    return tcp_connection


def main():
    parser = ArgumentParser()
    parser.add_argument("--track", "-t", help="a csv of keywords for filtering tweets")
    args = parser.parse_args()
    tcp_connection = start_socket_server()
    # TODO inject these via k8s secrets
    stream = TwitterStreamer(tcp_connection,
                             app_key=os.getenv('CONSUMER_KEY'),
                             app_secret=os.getenv('CONSUMER_SECRET'),
                             oauth_token=os.getenv('ACCESS_TOKEN'),
                             oauth_token_secret=os.getenv('ACCESS_SECRET'))
    stream.statuses.filter(track=args.track)
    print('Connected... Starting streaming tweets.')


if __name__ == "__main__":
    main()
