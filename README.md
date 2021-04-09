### RTMP HLS Streaming server in a Docker (Alpine)

[![Discord](https://img.shields.io/discord/720919856815276063)](https://discord.com/channels/720919856815276063/777186365921558569)  
[![CircleCI Build Status](https://img.shields.io/circleci/project/pozgo/docker-rtmp-hls/main.svg)](https://circleci.com/gh/pozgo/docker-rtmp-hls/tree/main)
[![GitHub Open Issues](https://img.shields.io/github/issues/pozgo/docker-rtmp-hls.svg)](https://github.com/pozgo/docker-rtmp-hls/issues)
[![GitHub Stars](https://img.shields.io/github/stars/pozgo/docker-rtmp-hls.svg)](https://github.com/pozgo/docker-rtmp-hls)
[![GitHub Forks](https://img.shields.io/github/forks/pozgo/docker-rtmp-hls.svg)](https://github.com/pozgo/docker-rtmp-hls)  
[![Stars on Docker Hub](https://img.shields.io/docker/stars/polinux/rtmp-hls.svg)](https://hub.docker.com/r/polinux/rtmp-hls)
[![Pulls on Docker Hub](https://img.shields.io/docker/pulls/polinux/rtmp-hls.svg)](https://hub.docker.com/r/polinux/rtmp-hls)  
[![](https://images.microbadger.com/badges/version/polinux/rtmp-hls.svg)](http://microbadger.com/images/polinux/rtmp-hls)
[![](https://images.microbadger.com/badges/license/polinux/rtmp-hls.svg)](http://microbadger.com/images/polinux/rtmp-hls)
[![](https://images.microbadger.com/badges/image/polinux/rtmp-hls.svg)](http://microbadger.com/images/polinux/rtmp-hls)  

Docker image for video streaming server that supports RTMP, HLS, and DASH streams.

## Description

This Docker image can be used to create a video streaming server that supports [**RTMP**](https://en.wikipedia.org/wiki/Real-Time_Messaging_Protocol), [**HLS**](https://en.wikipedia.org/wiki/HTTP_Live_Streaming), [**DASH**](https://en.wikipedia.org/wiki/Dynamic_Adaptive_Streaming_over_HTTP) out of the box. 
It also allows adaptive streaming and custom transcoding of video streams.
All modules are built from source on Alpine Linux and it's using Supervisor to start Nginx.

## Features
 * The backend is [**Nginx**](http://nginx.org/en/) with [**nginx-rtmp-module**](https://github.com/arut/nginx-rtmp-module).
 * [**FFmpeg**](https://www.ffmpeg.org/) for transcoding and adaptive streaming.
 * Default settings: 
	* RTMP is ON
	* HLS is ON (adaptive, 5 variants)
	* DASH is ON 
	* Other Nginx configuration files are also provided to allow for RTMP-only streams or no-FFmpeg transcoding. 
 * Statistic page of RTMP streams at `http://<server ip>:<server port>/stats`.
 * Available web video players (based on [video.js](https://videojs.com/) and [hls.js](https://github.com/video-dev/hls.js/)) at `/usr/local/nginx/html/players`. 

Current Image is built using:
 * Nginx `1.19.4` (compiled from source)
 * Nginx-rtmp-module `1.2.1` (compiled from source)
 * FFmpeg `4.3.1` (compiled from source)


## Usage

### To run the server
```
docker run -d -p 1935:1935 -p 8080:8080 polinux/rtmp-hls
```

### To stream to the server
 * **Stream live RTMP content to:**
	```
	rtmp://<server ip>:1935/live/<stream_key>
	```
	where `<stream_key>` is any stream key you specify.

 * **Configure [OBS](https://obsproject.com/) to stream content:** <br />
Go to Settings > Stream, choose the following settings:
   * Service: Custom Streaming Server.
   * Server: `rtmp://<server ip>:1935/live`. 
   * Stream key: anything you want

### To view the stream
 * **Using [VLC](https://www.videolan.org/vlc/index.html):**
	 * Go to Media > Open Network Stream.
	 * Enter the streaming URL: `rtmp://<server ip>:1935/live/<stream-key>`
	   Replace `<server ip>` with the IP of where the server is running, and
	   `<stream-key>` with the stream key you used when setting up the stream.
	 * For HLS and DASH, the URLs are of the forms: 
	 `http://<server ip>:8080/hls/<stream-key>.m3u8` and 
	 `http://<server ip>:8080/dash/<stream-key>_src.mpd` respectively.
	 * Click Play.

* **Using provided web player:** <br/>
The provided demo player can access any stream key that was set before.
	* To play RTMP content (requires Flash): `http://<server ip>:8080/player/?<stream-key>`

HLS player available at `http://<server ip>:8080/player/hls/?<stream-key>`  
DASH player available at `http://<server ip>:8080/player/dash/?<stream-key>`

### Example

1. Send live stream to `rtmp://<server_address>:1935/live/myStreamID`
2. Play stream in a web player at `http://<server_address>:8080/player/?myStreamID`

![image](images/example.gif)

Docker troubleshooting
======================

Use docker command to see if all required containers are up and running:
```
$ docker ps
```

Check logs of docker container:
```
$ docker logs rtmp
```

Sometimes you might just want to review how things are deployed inside a running
 container, you can do this by executing a _bash shell_ through _docker's
 exec_ command:
```
docker exec -ti rtmp /bin/bash
```

History of an image and size of layers:
```
docker history --no-trunc=true polinux/rtmp-hls | tr -s ' ' | tail -n+2 | awk -F " ago " '{print $2}'
```

## Author

Author: [Przemyslaw Ozgo](linux@ozgo.info)  
This work is also inspired by [TareqAlqutami](https://github.com/TareqAlqutami)'s [work](https://github.com/TareqAlqutami/rtmp-hls-server). Many thanks!
