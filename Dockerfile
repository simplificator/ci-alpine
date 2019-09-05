FROM alpine

# to run as Semaphore CI container, bash, git and lftp are required
RUN apk add --no-cache bash git lftp openssh-client libressl curl sudo
