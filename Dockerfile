FROM ubuntu:18.04

RUN ["apt","update"]
RUN ["apt","install","curl","gpg","xz-utils","-y"]
