# docker-nginx-imageresizer

This is an image resizer app based on Centos7 + Nginx + ngx_http_image_filter_module.

It can resize jpeg,png,gif formats on the fly specifying remote images

@Todo: base64 encode of the image if possible

@Todo: see how to manage images stored

Requiered:
put a directory ssh_keys into the project with your generated ssh keys


Example:
```
http://[host]:8999/resize/100x100/http://i0.wp.com/www.asphaltandrubber.com/wp-content/uploads/2014/11/2015-Aprilia-RSV4-RR-04.jpg
```
