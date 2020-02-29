# docker-antivirus

Yet another dockerized clamav clamd.

In this case it comes with a python cgi script, accepting form based file submit.

The response is in a legacy format, suitable for a proprietary application that I am involved with.

## Usage

    docker run -d -p 8080:80 logiva/antivirus

cURL example:

    curl -Ffiletocheck=@<(echo some file content) http://localhost:8080/av 

Also check the nice html form at 

    http://localhost:8080/avform

## More

Inspired by [dinkel](https://github.com/dinkel)

And [mko-x](https://github.com/mko-x)

