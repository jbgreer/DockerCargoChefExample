# official rust image
FROM rust

# copy app into image
COPY . /app

# set work directory
WORKDIR /app

# build all
RUN cargo build --release

# start app
CMD ["./target/release/actix-web-hello-1"]