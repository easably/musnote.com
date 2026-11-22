# SSH local forward only. The stem service on server7 listens on
# 127.0.0.1:8096. server8 can reach server7's SSH port and nothing else.
FROM alpine:3.21
RUN apk add --no-cache openssh-client
ENTRYPOINT ["ssh"]
