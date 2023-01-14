# STOLEN from Chris Hays:  see youtube.com/watch?v=xuqolj01D7M

# STAGE 1 : analyze source using rust image and cargo-chef
FROM rust as planner

WORKDIR /app

RUN cargo install cargo-chef

COPY . .

# cargo-chef prepare creates a recipe.json with dependencies
RUN cargo chef prepare --recipe-path recipe.json
 
# STAGE 2: build and cache dependencies
FROM rust as cacher

WORKDIR /app

RUN cargo install cargo-chef

COPY --from=planner /app/recipe.json recipe.json

RUN cargo chef cook --release --recipe-path recipe.json

# STAGE 3: build using official rust image
FROM rust as builder

#setup to run under regular user 'web'
 ENV USER=web
 ENV UID=1001

 RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistant" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    "${USER}"

# copy app into image
COPY . /app

# set work directory
WORKDIR /app

# copy cached dependencies from cacher stage
COPY --from=cacher /app/target target
COPY --from=cacher /usr/local/cargo /usr/local/cargo

# build 
RUN cargo build --release

# STAGE 4: run using Google distroless debian image for mostly statically compiled languages like rust
FROM gcr.io/distroless/cc-debian11

# copy runtime user info from builder
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group

# copy app from builder image
COPY --from=builder /app/target/release/actix-web-hello-1 /app/actix-web-hello-1

WORKDIR /app

# run as non-root user
USER web:web

# start app
CMD ["./actix-web-hello-1"]