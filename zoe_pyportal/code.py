import gc
import time
import adafruit_requests as requests
import adafruit_esp32spi.adafruit_esp32spi_socket as socket
from adafruit_esp32spi import adafruit_esp32spi
from adafruit_pyportal import PyPortal
import board
import busio
from digitalio import DigitalInOut

from secrets import secrets

spi = busio.SPI(board.SCK, board.MOSI, board.MISO)
esp = adafruit_esp32spi.ESP_SPIcontrol(
    spi,
    DigitalInOut(board.ESP_CS),
    DigitalInOut(board.ESP_BUSY),
    DigitalInOut(board.ESP_RESET)
)

print("Connecting to AP...")
while not esp.is_connected:
    try:
        esp.connect_AP(secrets['ssid'], secrets['password'])
    except RuntimeError as e:
        print("could not connect to AP, retrying: ", e)
        continue
print("Connected to", str(esp.ssid, 'utf-8'), "\tRSSI:", esp.rssi)

requests.set_socket(socket, esp)

# get access token
response = requests.post(
    "https://www.googleapis.com/oauth2/v4/token",
    json = {
        "client_id":        secrets['google_client_id'],
        "client_secret":    secrets['google_client_secret'],
        "grant_type":       "refresh_token",
        "refresh_token":    secrets['google_refresh_token']
    }
)
access_token = response.json()['access_token']

response = requests.post(
    "https://photoslibrary.googleapis.com/v1/mediaItems:search?prettyPrint=false",
    headers = {
        'Authorization': 'Bearer ' + access_token
    },
    json = {
        "albumId":      secrets['google_photos_shared_album_id'],
        "pageSize":     1
    },
    timeout = 0
)
photos = response.json()['mediaItems']
response.close()

# Set up where we'll be fetching data from
#DATA_SOURCE = "https://www.adafruit.com/api/quotes.php"
#QUOTE_LOCATION = [0, 'text']
#AUTHOR_LOCATION = [0, 'author']
#
# the current working directory (where this file is)
#cwd = ("/"+__file__).rsplit('/', 1)[0]
#pyportal = PyPortal(esp=esp,
#                    external_spi=spi,
#                    url=DATA_SOURCE,
#                    json_path=(QUOTE_LOCATION, AUTHOR_LOCATION),
#                    status_neopixel=board.NEOPIXEL,
#                    default_bg=cwd+"/quote_background.bmp",
#                    text_font=cwd+"/fonts/Arial-ItalicMT-17.bdf",
#                    text_position=((20, 120),  # quote location
#                                   (5, 210)), # author location
#                    text_color=(0xFFFFFF,  # quote text color
#                                0x8080FF), # author text color
#                    text_wrap=(35, # characters to wrap for quote
#                               0), # no wrap for author
#                    text_maxlen=(180, 30), # max text size for quote & author
#                   )
# speed up projects with lots of text by preloading the font!
#pyportal.preload_font()

#PyPortal.image_converter_url

pyportal = PyPortal(
    esp=esp,
    external_spi=spi,
)

image_url = photos[0]['baseUrl'] + "=w320-h240"
try:
    print("original URL:", image_url)
    image_url = pyportal.image_converter_url(image_url, 320, 240)
    print("convert URL:", image_url)
    # convert image to bitmap and cache
    #print("**not actually wgetting**")
    filename = "/cache.bmp"
    chunk_size = 12000      # default chunk size is 12K (for QSPI)
    if pyportal._sdcard:
        filename = "/sd" + filename
        chunk_size = 512  # current bug in big SD writes -> stick to 1 block
    try:
        pyportal.wget(image_url, filename, chunk_size=chunk_size)
    except OSError as error:
        print(error)
        raise OSError("""\n\nNo writable filesystem found for saving datastream. Insert an SD card or set internal filesystem to be unsafe by setting 'disable_concurrent_write_protection' in the mount options in boot.py""") # pylint: disable=line-too-long
    except RuntimeError as error:
        print(error)
        raise RuntimeError("wget didn't write a complete file")
    pyportal.set_background(filename, pyportal._image_position)
except ValueError as error:
    print("Error displaying cached image. " + error.args[0])
    pyportal.set_background(self._default_bg)
finally:
    image_url = None
    gc.collect()

while True:
    try:
#        value = pyportal.fetch()
#filename        print("Response is", value)
    except RuntimeError as e:
        print("Some error occured, retrying! -", e)
    time.sleep(60)
