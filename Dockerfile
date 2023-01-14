# build using official rust image
FROM rust as builder

# copy app into image
COPY . /app

# set work directory
WORKDIR /app

# build 
RUN cargo build --release

# run using Google distroless debian image for mostly statically compiled languages like rust
FROM gcr.io/distroless/cc-debian11

# copy app from builder image
COPY --from=builder /app/target/release/actix-web-hello-1 /app/actix-web-hello-1

WORKDIR /app

# start app
CMD ["./actix-web-hello-1"]