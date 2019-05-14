import os
import socket

from twython import TwythonStreamer


class TwitterStreamer(TwythonStreamer):

    def __init__(self, tcp_connection, *args, **kwargs):
        self.tcp_connection = tcp_connection
        super(TwitterStreamer, self).__init__(*args, **kwargs)

    def on_success(self, data):
        try:
            if data['lang'] == 'en':
                self.send_tweets_to_spark(data)
        except KeyError:
            print("Key [lang] not found, continue processing")

    def on_error(self, status_code, data):
        print(status_code, data)
        self.disconnect()

    def send_tweets_to_spark(self, tweet):
        print(tweet['id'])
        data = str(tweet['text']) + "\n"
        self.tcp_connection.send(data.encode())


def start_socket_server():
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.bind((os.getenv('TCP_IP'), int(os.getenv('TCP_PORT'))))
    s.listen(20)
    print('Waiting for TCP connection...')
    tcp_connection, addr = s.accept()
    return tcp_connection


def main():
    tcp_connection = start_socket_server()
    # TODO inject these via k8s secrets
    stream = TwitterStreamer(tcp_connection,
                             app_key=os.getenv('CONSUMER_KEY'),
                             app_secret=os.getenv('CONSUMER_SECRET'),
                             oauth_token=os.getenv('ACCESS_TOKEN'),
                             oauth_token_secret=os.getenv('ACCESS_SECRET'))
    # Start the stream
    stream.statuses.filter(track='trump,#trump')
    print('Connected... Starting streaming tweets.')


if __name__ == "__main__":
    main()
