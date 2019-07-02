import json
import logging
import os
import socket
import sys
from argparse import ArgumentParser

from twython import TwythonStreamer

logging.basicConfig(format='%(asctime)s %(levelname)-8s %(message)s', level=logging.INFO, datefmt='%Y-%m-%d %H:%M:%S')


class TwitterStreamer(TwythonStreamer):
    number_of_batches = 1
    batch_size = 500

    def __init__(self, tcp_connection, *args, **kwargs):
        self.tweets = []
        self.tcp_connection = tcp_connection
        super(TwitterStreamer, self).__init__(*args, **kwargs)

    def on_success(self, data: str) -> None:
        try:
            self.send_tweets_to_spark(data)
        except KeyError as err:
            logging.error(f"Error while parsing a tweet: {err}")
        except Exception as e:
            logging.error(f"Unexpected error: {sys.exc_info()[0]}")
            raise e

    def on_error(self, status_code: str, data: str) -> None:
        logging.error(f"{status_code} {data}")
        self.disconnect()

    def send_tweets_to_spark(self, tweet: str) -> None:
        self.tweets.append(json.dumps(tweet))
        if len(self.tweets) == self.batch_size:
            data = "\n".join(self.tweets)
            print(data)
            self.tcp_connection.send(data.encode(encoding='utf-8'))
            logging.info(f"Tweets sent to spark: {self.number_of_batches * self.batch_size}")
            self.number_of_batches += 1
            self.tweets = []


def start_socket_server() -> socket:
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.bind((os.getenv('TCP_IP'), int(os.getenv('TCP_PORT'))))
    s.listen(50)
    logging.info(f'Waiting for consumer TCP connection at {os.getenv("TCP_IP")}:{int(os.getenv("TCP_PORT"))} ...')
    tcp_connection, addr = s.accept()
    return tcp_connection


def main():
    parser = ArgumentParser()
    parser.add_argument("--track", "-t", required=True, help="a csv of keywords used when filtering tweets")
    args = parser.parse_args()
    logging.info(f'Setting up streaming with {args.track}')
    tcp_connection = start_socket_server()
    try:
        stream = TwitterStreamer(tcp_connection,
                                 app_key=os.getenv('CONSUMER_KEY'),
                                 app_secret=os.getenv('CONSUMER_SECRET'),
                                 oauth_token=os.getenv('ACCESS_TOKEN'),
                                 oauth_token_secret=os.getenv('ACCESS_SECRET'))
        stream.statuses.filter(track=args.track)
        logging.info('Connected... Starting streaming tweets.')
    except KeyboardInterrupt:
        logging.info('Closing producer.')


if __name__ == "__main__":
    main()
