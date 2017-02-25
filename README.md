# docker-nginx-imageresizer

This is an image resizer app based on Centos7 + Nginx + ngx_small_light + misc lua functions

It can resize jpeg, png, gif formats on the fly specifying remote images

By default, if your browser support webp, all images are converted to webp otherwise, 
it's converted to jpeg.

## Methods:

* o: keep original image (just proxy)
* r: resize proportional with borders
* rc: resize and crop
* rnb: resize proportional without borders (resize the bigger value among width and height)
* c: crop original image and possibility to change width and height in crop canvas
* rotate: rotate image
* w|h: resize proportional setting only the width or the height
* custom: small_light options (https://github.com/cubicdaiya/ngx_small_light)

## Example:
```
http://{host}:8888/o/{image_url_base64_encoded}
http://{host}:8888/{r|rc|rnb}/100x100-{color_code}-{format:webp|gif|png|jpg}[:{quality 0 to 100}]/{image_url_base64_encoded}
http://{host}:8888/{w|h}[-{format:webp|gif|png|jpg}:{quality 0 to 100}]/100/{image_url_base64_encoded}
http://{host}:8888/c/100x100[-{x-y}-{format:webp|gif|png|jpg}:{quality 0 to 100}]/{image_url_base64_encoded}
http://{host}:8888/rotate/{90|180|270}/{image_url_base64_encoded}
http://{host}:8888/custom/({small_light_options like dw=100,dh=100,of=webp})/{image_url_base64_encoded}
```

## Install

Requirements:
* docker
* docker-compose

```
docker-compose build
docker-compose up
```

## Connect on docker

```
ssh -p 2222 root@127.0.0.1
```

Credentials:
* root : password