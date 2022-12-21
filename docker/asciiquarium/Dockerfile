
FROM alpine:3.17

LABEL maintainer="tony.fischetti@gmail.com"

ARG USERNAME=marvin
ARG USER_UID=1000

RUN apk add wget perl-term-animation

# create non-root user
RUN adduser -u $USER_UID -S $USERNAME

USER $USERNAME
WORKDIR /home/$USERNAME

RUN wget --no-check-certificate "https://raw.githubusercontent.com/tonyfischetti/zix/master/bin/asciiquarium" && \
    chmod +x asciiquarium

CMD ["/home/marvin/asciiquarium"]

